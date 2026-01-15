#!/usr/bin/env node

/**
 * Sync script for flutter_lucide_animated
 *
 * Clones pqoqubbw/icons repository and parses TSX icon files
 * to generate JSON animation data and Dart code for the Flutter package.
 *
 * Usage:
 *   node sync.js              # Sync all icons
 *   node sync.js --limit 20   # Sync only first 20 icons (for testing)
 */

import { parse } from "@babel/parser";
import _traverse from "@babel/traverse";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { execSync } from "child_process";

// =============================================================================
// ESM Setup & Configuration
// =============================================================================

const traverse = _traverse.default || _traverse;
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CONFIG = {
  repoUrl: "https://github.com/pqoqubbw/icons.git",
  repoDir: path.join(__dirname, ".icons-repo"),
  iconsPath: "icons",
  // Dart output (for package)
  dartOutputDir: path.join(__dirname, "..", "lib", "lucide_animated"),
  dartIconsDir: path.join(__dirname, "..", "lib", "lucide_animated", "icons"),
};

const SVG_ELEMENT_TYPES = ["path", "circle", "rect", "line", "polyline", "ellipse", "polygon"];
const SVG_ATTRIBUTES = ["d", "cx", "cy", "r", "x", "y", "x1", "y1", "x2", "y2", "width", "height", "rx", "ry", "points"];

const EASING_MAP = {
  linear: "linear",
  easeIn: "easeIn",
  easeOut: "easeOut",
  easeInOut: "easeInOut",
  circIn: "easeInCirc",
  circOut: "easeOutCirc",
  circInOut: "easeInOutCirc",
  backIn: "easeInBack",
  backOut: "easeOutBack",
  backInOut: "easeInOutBack",
  spring: "easeOutBack",
};

// Parse CLI arguments
const args = process.argv.slice(2);
const limitIndex = args.indexOf("--limit");
const LIMIT = limitIndex !== -1 ? parseInt(args[limitIndex + 1]) : null;

// =============================================================================
// Repository Management
// =============================================================================

function cloneOrUpdateRepo() {
  const { repoDir, repoUrl } = CONFIG;

  if (fs.existsSync(repoDir)) {
    console.log("Updating icons repository...");
    try {
      execSync("git pull --ff-only", { cwd: repoDir, stdio: "pipe" });
      console.log("Repository updated");
    } catch {
      console.log("Pull failed, re-cloning...");
      fs.rmSync(repoDir, { recursive: true, force: true });
      execSync(`git clone --depth 1 ${repoUrl} ${repoDir}`, { stdio: "pipe" });
      console.log("Repository cloned");
    }
  } else {
    console.log("Cloning icons repository...");
    execSync(`git clone --depth 1 ${repoUrl} ${repoDir}`, { stdio: "pipe" });
    console.log("Repository cloned");
  }
}

function getIconList() {
  const iconsDir = path.join(CONFIG.repoDir, CONFIG.iconsPath);
  const files = fs.readdirSync(iconsDir);
  const icons = files
    .filter((f) => f.endsWith(".tsx"))
    .map((f) => f.replace(".tsx", ""));

  console.log(`Found ${icons.length} icons`);
  return icons;
}

function readIconSource(iconName) {
  const filePath = path.join(CONFIG.repoDir, CONFIG.iconsPath, `${iconName}.tsx`);
  return fs.readFileSync(filePath, "utf-8");
}

// =============================================================================
// JSX Element Helpers
// =============================================================================

/**
 * Get tag name from JSX opening element (handles both simple and member expressions)
 * @returns {{ type: 'simple' | 'member', name: string, object?: string, property?: string } | null}
 */
function getJSXTagInfo(openingElement) {
  const name = openingElement.name;
  if (!name) return null;

  // Simple JSX identifier: <path>, <circle>, <svg>
  if (name.type === "JSXIdentifier") {
    return { type: "simple", name: name.name };
  }

  // Member expression: <motion.path>, <motion.svg>
  if (
    name.type === "JSXMemberExpression" &&
    name.object?.type === "JSXIdentifier" &&
    name.property?.type === "JSXIdentifier"
  ) {
    return {
      type: "member",
      name: `${name.object.name}.${name.property.name}`,
      object: name.object.name,
      property: name.property.name,
    };
  }

  return null;
}

/**
 * Check if element is an SVG element
 */
function isSvgElement(tagInfo) {
  return (
    (tagInfo?.type === "simple" && tagInfo.name === "svg") ||
    (tagInfo?.type === "member" && tagInfo.object === "motion" && tagInfo.property === "svg")
  );
}

/**
 * Extract attribute value from JSX attribute
 */
function getAttributeValue(attr) {
  if (!attr.value) return null;

  if (attr.value.type === "StringLiteral") {
    return attr.value.value;
  }

  if (attr.value.type === "JSXExpressionContainer") {
    return extractASTValue(attr.value.expression);
  }

  return null;
}

// =============================================================================
// AST Value Extraction
// =============================================================================

/**
 * Extract JavaScript value from AST node
 */
function extractASTValue(node) {
  if (!node) return null;

  switch (node.type) {
    case "NumericLiteral":
    case "StringLiteral":
    case "BooleanLiteral":
      return node.value;

    case "ArrayExpression":
      return node.elements.map(extractASTValue);

    case "ObjectExpression": {
      const obj = {};
      for (const prop of node.properties) {
        if (prop.type === "SpreadElement" || !prop.key) continue;
        const key = prop.key.name || prop.key.value;
        obj[key] = extractASTValue(prop.value);
      }
      return obj;
    }

    case "UnaryExpression":
      if (node.operator === "-") {
        return -extractASTValue(node.argument);
      }
      return null;

    case "Identifier":
      if (node.name === "Infinity") return 999999;
      // Return null for unresolved variable references (not the variable name)
      return null;

    case "TemplateLiteral":
      // Handle template literals like `${value}deg`
      if (node.quasis?.length > 0 && node.expressions?.length > 0) {
        const value = extractASTValue(node.expressions[0]);
        if (value !== null) return value;
      }
      return null;

    default:
      return null;
  }
}

// =============================================================================
// Icon Parsing (Single-Pass AST Traversal)
// =============================================================================

/**
 * Parse TSX source and extract icon data in a single AST traversal
 */
function parseIconSource(iconName, source) {
  const iconData = {
    name: iconName,
    viewBox: "0 0 24 24",
    strokeWidth: 2,
    strokeLinecap: "round",
    strokeLinejoin: "round",
    elements: [],
    animation: null,
  };

  try {
    const ast = parse(source, {
      sourceType: "module",
      plugins: ["jsx", "typescript"],
    });

    // Collect all data in a single traversal
    const parseContext = {
      variantsMap: {},  // Map of variant name -> variant object (e.g., PATH_VARIANTS -> {normal: ..., animate: ...})
      defaultVariants: {},  // Fallback variants
      transition: { duration: 0.4, ease: "easeOut" },
      arrayVars: {},
      pathArrays: [],
      circleArrays: [],
      viewBoxSize: 24,
      pathArraysUsed: false,
      circleArraysUsed: false,
    };

    // Single traversal to collect all needed data
    traverse(ast, {
      // Collect variable declarations (variants, arrays, transition)
      VariableDeclarator(varPath) {
        collectVariableDeclaration(varPath.node, parseContext);
      },

      // Collect transition from object properties
      ObjectProperty(propPath) {
        const key = propPath.node.key.name || propPath.node.key.value;
        if (key === "transition" && propPath.node.value.type === "ObjectExpression") {
          parseContext.transition = extractASTValue(propPath.node.value);
        }
      },

      // Collect array.map() calls
      CallExpression(callPath) {
        collectMapExpression(callPath.node, parseContext);
      },

      // Process JSX elements
      JSXElement(jsxPath) {
        processJSXElement(jsxPath, iconData, parseContext);
      },
    });

    // Deduplicate elements
    iconData.elements = deduplicateElements(iconData.elements);
  } catch (error) {
    console.error(`Error parsing ${iconName}: ${error.message}`);
  }

  return iconData;
}

/**
 * Collect variable declarations (variants and arrays)
 */
function collectVariableDeclaration(node, ctx) {
  const id = node.id;
  const init = node.init;
  if (!id || id.type !== "Identifier" || !init) return;

  // Collect VARIANTS objects - store by variable name
  if (id.name.includes("VARIANTS") || id.name.includes("variants")) {
    if (init.type === "ObjectExpression") {
      const variantObj = {};
      for (const prop of init.properties) {
        if (prop.type === "SpreadElement" || !prop.key) continue;
        const key = prop.key.name || prop.key.value;
        variantObj[key] = extractASTValue(prop.value);
      }
      // Store by variable name (e.g., PATH_VARIANTS, ARROW_VARIANTS)
      ctx.variantsMap[id.name] = variantObj;
      // Also set as default if it's the first one
      if (Object.keys(ctx.defaultVariants).length === 0) {
        ctx.defaultVariants = variantObj;
      }
    }
  }

  // Collect array variables for .map() patterns
  if (init.type === "ArrayExpression") {
    const items = [];
    for (const el of init.elements) {
      if (!el) continue;
      if (el.type === "StringLiteral") {
        items.push(el.value);
      } else if (el.type === "ObjectExpression") {
        const obj = {};
        for (const prop of el.properties) {
          if (!prop.key || !prop.value) continue;
          const key = prop.key.name || prop.key.value;
          if (prop.value.type === "NumericLiteral" || prop.value.type === "StringLiteral") {
            obj[key] = prop.value.value;
          }
        }
        if (Object.keys(obj).length > 0) items.push(obj);
      }
    }
    if (items.length > 0) {
      ctx.arrayVars[id.name] = items;
    }
  }
}

/**
 * Collect paths/circles from .map() expressions
 */
function collectMapExpression(node, ctx) {
  if (node.callee.type !== "MemberExpression") return;
  if (node.callee.property?.name !== "map") return;

  const array = node.callee.object;

  // Inline array: ["path1", "path2"].map(...)
  if (array.type === "ArrayExpression") {
    for (const el of array.elements) {
      if (el?.type === "StringLiteral") {
        ctx.pathArrays.push(el.value);
      }
    }
  }

  // Variable reference: PATHS.map(...), CIRCLES.map(...)
  if (array.type === "Identifier" && ctx.arrayVars[array.name]) {
    for (const item of ctx.arrayVars[array.name]) {
      if (typeof item === "string") {
        ctx.pathArrays.push(item);
      } else if (typeof item === "object") {
        if (item.cx !== undefined) {
          ctx.circleArrays.push(item);
        } else if (item.d !== undefined) {
          ctx.pathArrays.push(item.d);
        }
      }
    }
  }
}

/**
 * Get variants for an element by looking at its variants attribute
 */
function getVariantsForElement(openingElement, ctx) {
  // Look for variants={SOME_VARIANTS} attribute
  for (const attr of openingElement.attributes) {
    if (attr.type !== "JSXAttribute") continue;
    if (attr.name?.name !== "variants") continue;
    if (attr.value?.type === "JSXExpressionContainer") {
      const expr = attr.value.expression;
      if (expr.type === "Identifier") {
        const variantName = expr.name;
        if (ctx.variantsMap[variantName]) {
          return ctx.variantsMap[variantName];
        }
      }
    }
  }
  // Fallback to default variants
  return ctx.defaultVariants;
}

/**
 * Process a JSX element and add to icon data
 */
function processJSXElement(jsxPath, iconData, ctx) {
  const openingElement = jsxPath.node.openingElement;
  const tagInfo = getJSXTagInfo(openingElement);
  if (!tagInfo) return;

  // Extract viewBox from SVG element
  if (isSvgElement(tagInfo)) {
    extractViewBox(openingElement, iconData, ctx);
    if (tagInfo.type === "member") {
      const svgVariants = getVariantsForElement(openingElement, ctx);
      iconData.animation = determineAnimation(svgVariants, ctx.transition);
    }
    return;
  }

  // Check if inside a .map() call
  const isInMap = jsxPath.parent?.type === "ArrowFunctionExpression";

  // Handle motion elements
  if (tagInfo.type === "member" && tagInfo.object === "motion") {
    const elementType = tagInfo.property;
    const elementVariants = getVariantsForElement(openingElement, ctx);

    // Mapped path elements
    if (isInMap && elementType === "path" && ctx.pathArrays.length > 0 && !ctx.pathArraysUsed) {
      for (const d of ctx.pathArrays) {
        const element = { type: "path", d, animation: determineAnimation(elementVariants, ctx.transition) };
        if (validateElement(element, ctx.viewBoxSize)) {
          iconData.elements.push(element);
        }
      }
      ctx.pathArraysUsed = true;
      return;
    }

    // Mapped circle elements
    if (isInMap && elementType === "circle" && ctx.circleArrays.length > 0 && !ctx.circleArraysUsed) {
      const r = extractAttributeFromElement(openingElement, "r") || "1";
      for (const circleData of ctx.circleArrays) {
        const element = {
          type: "circle",
          cx: String(circleData.cx),
          cy: String(circleData.cy),
          r,
          animation: determineAnimation(elementVariants, ctx.transition),
        };
        if (validateElement(element, ctx.viewBoxSize)) {
          iconData.elements.push(element);
        }
      }
      ctx.circleArraysUsed = true;
      return;
    }

    // Regular motion element (not mapped)
    if (!isInMap && SVG_ELEMENT_TYPES.includes(elementType)) {
      const element = extractElement(elementType, openingElement.attributes, ctx, elementVariants);
      if (element) iconData.elements.push(element);
    }
    return;
  }

  // Handle regular SVG elements
  if (tagInfo.type === "simple" && SVG_ELEMENT_TYPES.includes(tagInfo.name)) {
    const element = extractElement(tagInfo.name, openingElement.attributes, ctx, ctx.defaultVariants);
    if (element) iconData.elements.push(element);
  }
}

/**
 * Extract viewBox from SVG element
 */
function extractViewBox(openingElement, iconData, ctx) {
  for (const attr of openingElement.attributes) {
    if (attr.type !== "JSXAttribute") continue;
    if (attr.name?.name !== "viewBox") continue;
    if (attr.value?.type !== "StringLiteral") continue;

    const vb = attr.value.value;
    const parts = vb.split(/\s+/);
    if (parts.length >= 4) {
      ctx.viewBoxSize = Math.max(parseFloat(parts[2]), parseFloat(parts[3]));
      iconData.viewBox = vb;
    }
  }
}

/**
 * Extract a specific attribute from an opening element
 */
function extractAttributeFromElement(openingElement, attrName) {
  for (const attr of openingElement.attributes) {
    if (attr.type !== "JSXAttribute") continue;
    if (attr.name?.name !== attrName) continue;
    return getAttributeValue(attr);
  }
  return null;
}

// =============================================================================
// Element Extraction & Validation
// =============================================================================

/**
 * Extract SVG element data from JSX attributes
 */
function extractElement(type, attributes, ctx, variants) {
  if (type === "svg" || type === "g") return null;

  const element = { type };

  for (const attr of attributes) {
    if (attr.type !== "JSXAttribute") continue;
    const name = attr.name?.name;
    if (!name || !SVG_ATTRIBUTES.includes(name)) continue;
    element[name] = getAttributeValue(attr);
  }

  if (!validateElement(element, ctx.viewBoxSize)) return null;

  const animation = determineAnimation(variants || ctx.defaultVariants, ctx.transition);
  if (animation) element.animation = animation;

  return element;
}

/**
 * Validate element has valid data
 */
function validateElement(element, viewBoxSize = 24) {
  const { type } = element;
  const maxCoord = viewBoxSize * 1.1;

  switch (type) {
    case "path": {
      const { d } = element;
      if (!d || d === "d" || (typeof d === "string" && !d.trim().match(/^[Mm]/))) {
        return false;
      }
      // Note: We don't validate path numbers strictly because SVG paths can have
      // arc parameters, bezier control points, etc. that exceed viewBox bounds
      return true;
    }

    case "circle": {
      const cx = parseFloat(element.cx);
      const cy = parseFloat(element.cy);
      const r = parseFloat(element.r);
      if (isNaN(cx) || isNaN(cy) || isNaN(r)) return false;
      if (cx > maxCoord || cy > maxCoord || r > maxCoord) return false;
      return true;
    }

    case "polyline":
    case "polygon":
      return element.points && typeof element.points === "string" && element.points.trim() !== "";

    case "line":
      return element.x1 != null && element.y1 != null && element.x2 != null && element.y2 != null;

    case "rect":
      return true;

    case "ellipse":
      return true;

    default:
      return true;
  }
}

/**
 * Deduplicate elements based on unique key
 */
function deduplicateElements(elements) {
  const seen = new Set();
  return elements.filter((el) => {
    const key = getElementKey(el);
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

/**
 * Generate unique key for an element
 */
function getElementKey(element) {
  switch (element.type) {
    case "path":
      return `path:${element.d}`;
    case "circle":
      return `circle:${element.cx},${element.cy},${element.r}`;
    case "line":
      return `line:${element.x1},${element.y1},${element.x2},${element.y2}`;
    case "polyline":
    case "polygon":
      return `${element.type}:${element.points}`;
    case "rect":
      return `rect:${element.x},${element.y},${element.width},${element.height}`;
    default:
      return `${element.type}:${JSON.stringify(element)}`;
  }
}

// =============================================================================
// Animation Detection
// =============================================================================

/**
 * Determine animation type from variants and transition
 */
function determineAnimation(variants, transition) {
  if (!variants || Object.keys(variants).length === 0) return null;

  const normal = variants.normal || variants.initial || {};
  const animate = variants.animate || variants.hover || {};

  const baseAnimation = {
    duration: Math.round((transition.duration || 0.4) * 1000),
    delay: Math.round((transition.delay ?? 0) * 1000),
    easing: mapEasing(transition.ease || transition.type || "easeOut"),
  };

  // PathLength animation
  if ("pathLength" in animate || "pathLength" in normal) {
    return buildPathLengthAnimation(normal, animate, baseAnimation);
  }

  // Opacity animation
  if ("opacity" in animate || "opacity" in normal) {
    return buildOpacityAnimation(normal, animate, baseAnimation);
  }

  // Rotate animation
  if ("rotate" in animate || "rotate" in normal) {
    return buildRotateAnimation(normal, animate, baseAnimation);
  }

  // Translate animation
  if ("x" in animate || "y" in animate || "x" in normal || "y" in normal) {
    return buildTranslateAnimation(normal, animate, baseAnimation);
  }

  // Scale animation
  if ("scale" in animate || "scale" in normal) {
    const from = normal.scale ?? 1;
    const to = animate.scale ?? 1;
    // Handle keyframe scale (when to is a list)
    if (Array.isArray(to)) {
      const keyframes = filterNulls(to);
      if (keyframes.length === 0) return null;
      return { type: "scale", from, to: keyframes, ...baseAnimation };
    }
    return { type: "scale", from, to, ...baseAnimation };
  }

  return null;
}

function buildPathLengthAnimation(normal, animate, base) {
  let from = Array.isArray(animate.pathLength) ? animate.pathLength[0] : (normal.pathLength ?? 0);
  let to = Array.isArray(animate.pathLength) ? animate.pathLength[1] : (animate.pathLength ?? 1);

  if (from === 0 && to === 0) {
    from = 0;
    to = 1;
  }

  // Combined with opacity
  if ("opacity" in animate || "opacity" in normal) {
    let opFrom = Array.isArray(animate.opacity) ? animate.opacity[0] : (normal.opacity ?? 0);
    let opTo = Array.isArray(animate.opacity) ? animate.opacity[1] : (animate.opacity ?? 1);
    ({ from: opFrom, to: opTo } = fixOpacity(opFrom, opTo));

    return {
      type: "combined",
      pathLength: { from, to },
      opacity: { from: opFrom, to: opTo },
      ...base,
    };
  }

  return { type: "pathLength", from, to, ...base };
}

function buildOpacityAnimation(normal, animate, base) {
  let from = Array.isArray(animate.opacity) ? animate.opacity[0] : (normal.opacity ?? 0);
  let to = Array.isArray(animate.opacity) ? animate.opacity[1] : (animate.opacity ?? 1);

  ({ from, to } = fixOpacity(from, to));

  // Convert static opacity to pathLength for better animation
  if (from === 0 && to === 1) {
    return { type: "pathLength", from: 0, to: 1, ...base };
  }

  return { type: "opacity", from, to, ...base };
}

/**
 * Parse a degree value (handles numbers and strings like "0deg", "-50deg")
 */
function parseDegrees(value) {
  if (typeof value === "number") return value;
  if (typeof value === "string") {
    const match = value.match(/^(-?\d+(?:\.\d+)?)(deg)?$/);
    if (match) return parseFloat(match[1]);
  }
  return null;
}

/**
 * Filter null/undefined values from an array
 */
function filterNulls(arr) {
  return arr.filter(v => v !== null && v !== undefined);
}

function buildRotateAnimation(normal, animate, base) {
  if (Array.isArray(animate.rotate)) {
    const keyframes = filterNulls(animate.rotate.map(parseDegrees));
    if (keyframes.length === 0) return null;
    return { type: "rotateKeyframe", keyframes, origin: "center", ...base };
  }
  const from = parseDegrees(normal.rotate) ?? 0;
  const to = parseDegrees(animate.rotate) ?? 360;
  return { type: "rotate", from, to, origin: "center", ...base };
}

function buildTranslateAnimation(normal, animate, base) {
  if (Array.isArray(animate.x) || Array.isArray(animate.y)) {
    // Ensure keyframes are always arrays and filter nulls
    const keyframesX = filterNulls(Array.isArray(animate.x) ? animate.x : [animate.x ?? 0]);
    const keyframesY = filterNulls(Array.isArray(animate.y) ? animate.y : [animate.y ?? 0]);
    // Ensure we have at least one value
    if (keyframesX.length === 0) keyframesX.push(0);
    if (keyframesY.length === 0) keyframesY.push(0);
    return {
      type: "translateKeyframe",
      keyframesX,
      keyframesY,
      ...base,
    };
  }
  return {
    type: "translate",
    fromX: normal.x ?? 0,
    toX: animate.x ?? 0,
    fromY: normal.y ?? 0,
    toY: animate.y ?? 0,
    ...base,
  };
}

/**
 * Fix problematic opacity values
 */
function fixOpacity(from, to) {
  // Fix fade-out to fade-in (reverse any fade-out animation)
  if (from > to) return { from: to, to: from };
  // Fix static opacity to fade-in
  if (from === to) return { from: 0, to: 1 };
  return { from, to };
}

/**
 * Map framer-motion easing to Flutter curve name
 */
function mapEasing(ease) {
  if (typeof ease === "string") {
    return EASING_MAP[ease] || "easeOut";
  }
  return "easeOut";
}

// =============================================================================
// Dart Code Generation
// =============================================================================

const DART_EASING_MAP = {
  linear: "Curves.linear",
  easeIn: "Curves.easeIn",
  easeOut: "Curves.easeOut",
  easeInOut: "Curves.easeInOut",
  easeInCirc: "Curves.easeInCirc",
  easeOutCirc: "Curves.easeOutCirc",
  easeInOutCirc: "Curves.easeInOutCirc",
  easeInBack: "Curves.easeInBack",
  easeOutBack: "Curves.easeOutBack",
  easeInOutBack: "Curves.easeInOutBack",
};

function toSnakeCase(name) {
  return name.replace(/-/g, "_");
}

function getDartCurve(easing) {
  return DART_EASING_MAP[easing] || "Curves.easeOut";
}

function generateDartAnimation(animation) {
  if (!animation) return null;

  const { type, duration = 400, delay = 0, easing = "easeOut" } = animation;
  const curve = getDartCurve(easing);
  const durationMs = `Duration(milliseconds: ${duration})`;
  const delayMs = delay > 0 ? `delay: Duration(milliseconds: ${delay}),` : "";

  switch (type) {
    case "pathLength": {
      const from = animation.from ?? 0;
      const to = animation.to ?? 1;
      return `PathLengthAnimation(from: ${from}, to: ${to}, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
    }

    case "opacity": {
      let from = animation.from ?? 0;
      let to = animation.to ?? 1;
      if (from === 0 && to === 0) to = 1;
      if (from === to) return `PathLengthAnimation(from: 0, to: 1, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
      return `OpacityAnimation(from: ${from}, to: ${to}, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
    }

    case "rotate": {
      const from = animation.from ?? 0;
      const to = animation.to ?? 360;
      return `RotateAnimation(fromDegrees: ${from}, toDegrees: ${to}, duration: ${durationMs}, ${delayMs} curve: ${curve}, origin: Alignment.center)`;
    }

    case "rotateKeyframe": {
      const keyframes = JSON.stringify(animation.keyframes || [0]);
      return `RotateKeyframeAnimation(keyframes: ${keyframes}, duration: ${durationMs}, ${delayMs} curve: ${curve}, origin: Alignment.center)`;
    }

    case "translate": {
      const { fromX = 0, toX = 0, fromY = 0, toY = 0 } = animation;
      return `TranslateAnimation(fromX: ${fromX}, toX: ${toX}, fromY: ${fromY}, toY: ${toY}, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
    }

    case "translateKeyframe": {
      const keyframesX = JSON.stringify(animation.keyframesX || [0]);
      const keyframesY = JSON.stringify(animation.keyframesY || [0]);
      return `TranslateKeyframeAnimation(keyframesX: ${keyframesX}, keyframesY: ${keyframesY}, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
    }

    case "scale": {
      const from = animation.from ?? 1;
      const to = animation.to ?? 1;
      if (Array.isArray(to)) {
        return `ScaleKeyframeAnimation(keyframes: ${JSON.stringify(to)}, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
      }
      return `ScaleAnimation(from: ${from}, to: ${to}, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
    }

    case "combined": {
      const parts = [];
      if (animation.pathLength) {
        const { from = 0, to = 1 } = animation.pathLength;
        parts.push(`pathLength: PathLengthAnimation(from: ${from}, to: ${to}, duration: ${durationMs}, curve: ${curve})`);
      }
      if (animation.opacity) {
        let { from = 0, to = 1 } = animation.opacity;
        if (from === 0 && to === 0) to = 1;
        if (from !== to) {
          parts.push(`opacity: OpacityAnimation(from: ${from}, to: ${to}, duration: ${durationMs}, curve: ${curve})`);
        }
      }
      if (parts.length === 0) {
        return `PathLengthAnimation(from: 0, to: 1, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
      }
      return `CombinedAnimation(${parts.join(", ")}, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
    }

    default:
      return `PathLengthAnimation(from: 0, to: 1, duration: ${durationMs}, ${delayMs} curve: ${curve})`;
  }
}

function generateDartElement(element, index) {
  const defaultAnim = `PathLengthAnimation(from: 0, to: 1, duration: Duration(milliseconds: 400), delay: Duration(milliseconds: ${index * 50}), curve: Curves.easeOut)`;
  const animation = element.animation ? generateDartAnimation(element.animation) : defaultAnim;

  switch (element.type) {
    case "path": {
      const d = element.d || "";
      if (!d.trim().match(/^[Mm]/)) return null;
      return `PathElement(d: '${d}', animation: ${animation})`;
    }

    case "circle": {
      const cx = parseFloat(element.cx) || 0;
      const cy = parseFloat(element.cy) || 0;
      const r = parseFloat(element.r) || 0;
      if (cx > 50 || cy > 50 || r > 50) return null;
      return `CircleElement(cx: ${cx}, cy: ${cy}, r: ${r}, animation: ${animation})`;
    }

    case "rect": {
      const { x = 0, y = 0, width = 0, height = 0, rx = 0, ry = 0 } = element;
      return `RectElement(x: ${x}, y: ${y}, width: ${width}, height: ${height}, rx: ${rx}, ry: ${ry}, animation: ${animation})`;
    }

    case "line": {
      const { x1 = 0, y1 = 0, x2 = 0, y2 = 0 } = element;
      return `LineElement(x1: ${x1}, y1: ${y1}, x2: ${x2}, y2: ${y2}, animation: ${animation})`;
    }

    case "polyline": {
      const points = element.points || "";
      return `PolylineElement(points: '${points}', animation: ${animation})`;
    }

    case "polygon": {
      const points = element.points || "";
      return `PolygonElement(points: '${points}', animation: ${animation})`;
    }

    default:
      return null;
  }
}

function generateDartIcon(iconData) {
  const varName = toSnakeCase(iconData.name);
  const viewBoxParts = iconData.viewBox.split(" ").map(Number);
  const viewBoxWidth = viewBoxParts[2] || 24;
  const viewBoxHeight = viewBoxParts[3] || 24;

  const lines = [
    "// GENERATED CODE - DO NOT MODIFY BY HAND",
    "// Run `node scripts/sync.js` to regenerate",
    "// ignore_for_file: constant_identifier_names",
    "",
    "import 'package:flutter/widgets.dart';",
    "import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';",
    "",
    `/// [${iconData.name}] lucide animated icon.`,
    `const ${varName} = LucideAnimatedIconData(`,
    `  name: '${iconData.name}',`,
    `  viewBoxWidth: ${viewBoxWidth}.0,`,
    `  viewBoxHeight: ${viewBoxHeight}.0,`,
    `  strokeWidth: ${iconData.strokeWidth}.0,`,
  ];

  if (iconData.animation) {
    const anim = generateDartAnimation(iconData.animation);
    if (anim) {
      lines.push(`  animation: ${anim},`);
    }
  }

  lines.push("  elements: [");

  let elementIndex = 0;
  for (const element of iconData.elements) {
    const dartElement = generateDartElement(element, elementIndex);
    if (dartElement) {
      lines.push(`    ${dartElement},`);
      elementIndex++;
    }
  }

  lines.push("  ],");
  lines.push(");");
  lines.push("");

  return lines.join("\n");
}

function writeIconDart(iconData) {
  const fileName = `${toSnakeCase(iconData.name)}.g.dart`;
  const filePath = path.join(CONFIG.dartIconsDir, fileName);
  const dartCode = generateDartIcon(iconData);
  fs.writeFileSync(filePath, dartCode);
}

function writeBarrelExport(iconNames) {
  const sortedNames = iconNames.sort();
  const lines = [
    "// GENERATED CODE - DO NOT MODIFY BY HAND",
    "// Run `node scripts/sync.js` to regenerate",
    `// ${sortedNames.length} animated Lucide icons for Flutter`,
    "",
  ];

  for (const name of sortedNames) {
    const fileName = toSnakeCase(name);
    lines.push(`export 'icons/${fileName}.g.dart';`);
  }

  lines.push("");

  const filePath = path.join(CONFIG.dartOutputDir, "lucide_animated.dart");
  fs.writeFileSync(filePath, lines.join("\n"));
}

// =============================================================================
// Main Entry Point
// =============================================================================

function main() {
  console.log("flutter_lucide_animated sync");
  console.log("============================");
  console.log("");

  cloneOrUpdateRepo();
  console.log("");

  // Create output directory
  fs.mkdirSync(CONFIG.dartIconsDir, { recursive: true });

  let iconNames = getIconList();
  if (LIMIT) {
    console.log(`Limiting to first ${LIMIT} icons (test mode)`);
    iconNames = iconNames.slice(0, LIMIT);
  }

  console.log("");
  console.log("Syncing icons...");

  const successfulIcons = [];
  const failedIcons = [];

  for (let i = 0; i < iconNames.length; i++) {
    const iconName = iconNames[i];
    const progress = `[${i + 1}/${iconNames.length}]`;

    try {
      process.stdout.write(`${progress} ${iconName}... `);

      const source = readIconSource(iconName);
      const iconData = parseIconSource(iconName, source);

      if (iconData.elements.length > 0) {
        writeIconDart(iconData);
        successfulIcons.push(iconName);
        console.log("done");
      } else {
        console.log("skipped (no elements)");
        failedIcons.push(iconName);
      }
    } catch (error) {
      console.log(`failed (${error.message})`);
      failedIcons.push(iconName);
    }
  }

  console.log("");
  console.log("Writing barrel export...");
  writeBarrelExport(successfulIcons);

  console.log("");
  console.log("============================");
  console.log(`Synced: ${successfulIcons.length} icons`);
  if (failedIcons.length > 0) {
    console.log(`Failed: ${failedIcons.length} icons`);
  }
  console.log(`Output: ${CONFIG.dartIconsDir}`);
}

main();

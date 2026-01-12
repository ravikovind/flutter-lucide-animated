#!/usr/bin/env node

/**
 * Sync script for flutter_lucide_animated
 *
 * Fetches TSX icon files from pqoqubbw/icons repository,
 * parses the animation data, and outputs JSON files for the Flutter package.
 *
 * Usage:
 *   node sync.js              # Sync all icons
 *   node sync.js --limit 20   # Sync only first 20 icons (for testing)
 */

import { parse } from '@babel/parser';
import _traverse from '@babel/traverse';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Handle ESM default export
const traverse = _traverse.default || _traverse;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration
const GITHUB_API = 'https://api.github.com';
const REPO_OWNER = 'pqoqubbw';
const REPO_NAME = 'icons';
const ICONS_PATH = 'icons';
const RAW_BASE = `https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main`;

const OUTPUT_DIR = path.join(__dirname, '..', 'docs', 'v1');
const ICONS_OUTPUT_DIR = path.join(OUTPUT_DIR, 'icons');

// Parse command line arguments
const args = process.argv.slice(2);
const limitIndex = args.indexOf('--limit');
const LIMIT = limitIndex !== -1 ? parseInt(args[limitIndex + 1]) : null;

/**
 * Fetch list of icon files from GitHub API
 */
async function fetchIconList() {
  console.log('Fetching icon list from GitHub...');

  const response = await fetch(`${GITHUB_API}/repos/${REPO_OWNER}/${REPO_NAME}/contents/${ICONS_PATH}`);

  if (!response.ok) {
    throw new Error(`Failed to fetch icon list: ${response.status}`);
  }

  const files = await response.json();
  const tsxFiles = files
    .filter(f => f.name.endsWith('.tsx'))
    .map(f => f.name.replace('.tsx', ''));

  console.log(`Found ${tsxFiles.length} icons`);
  return tsxFiles;
}

/**
 * Fetch a single TSX file content
 */
async function fetchIconSource(iconName) {
  const url = `${RAW_BASE}/${ICONS_PATH}/${iconName}.tsx`;
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Failed to fetch ${iconName}: ${response.status}`);
  }

  return await response.text();
}

/**
 * Parse TSX source and extract icon data
 */
function parseIconSource(iconName, source) {
  const iconData = {
    name: iconName,
    viewBox: '0 0 24 24',
    strokeWidth: 2,
    strokeLinecap: 'round',
    strokeLinejoin: 'round',
    elements: [],
    animation: null,
  };

  try {
    const ast = parse(source, {
      sourceType: 'module',
      plugins: ['jsx', 'typescript'],
    });

    // Extract variants/animation data
    const variants = extractVariants(ast);
    const transition = extractTransition(ast);

    // Extract SVG elements
    traverse(ast, {
      JSXElement(path) {
        const openingElement = path.node.openingElement;
        const tagName = openingElement.name.name;

        // Handle motion.path, motion.circle, etc.
        if (openingElement.name.type === 'JSXMemberExpression') {
          const object = openingElement.name.object.name;
          const property = openingElement.name.property.name;

          if (object === 'motion') {
            const element = extractElement(property, openingElement.attributes, variants, transition);
            if (element) {
              iconData.elements.push(element);
            }
          }
        }

        // Handle regular SVG elements
        if (['path', 'circle', 'rect', 'line', 'polyline', 'ellipse'].includes(tagName)) {
          const element = extractElement(tagName, openingElement.attributes, variants, transition);
          if (element) {
            iconData.elements.push(element);
          }
        }

        // Handle motion.svg for icon-level animations
        if (openingElement.name.type === 'JSXMemberExpression') {
          const object = openingElement.name.object.name;
          const property = openingElement.name.property.name;

          if (object === 'motion' && property === 'svg') {
            iconData.animation = extractIconAnimation(openingElement.attributes, variants, transition);
          }
        }
      },
    });

    // If no elements found with animation, check for regular SVG
    if (iconData.elements.length === 0) {
      traverse(ast, {
        JSXElement(path) {
          const openingElement = path.node.openingElement;
          const tagName = openingElement.name.name;

          if (['path', 'circle', 'rect', 'line', 'polyline'].includes(tagName)) {
            const element = extractElement(tagName, openingElement.attributes, {}, transition);
            if (element) {
              iconData.elements.push(element);
            }
          }
        },
      });
    }

  } catch (error) {
    console.error(`Error parsing ${iconName}: ${error.message}`);
  }

  return iconData;
}

/**
 * Extract variants object from AST
 */
function extractVariants(ast) {
  const variants = {};

  traverse(ast, {
    VariableDeclarator(path) {
      const id = path.node.id;
      const init = path.node.init;

      // Look for *_VARIANTS or variants pattern
      if (id.name && (id.name.includes('VARIANTS') || id.name.includes('variants'))) {
        if (init && init.type === 'ObjectExpression') {
          for (const prop of init.properties) {
            if (prop.key && prop.value) {
              const key = prop.key.name || prop.key.value;
              variants[key] = extractObjectValue(prop.value);
            }
          }
        }
      }
    },
  });

  return variants;
}

/**
 * Extract transition config from AST
 */
function extractTransition(ast) {
  let transition = { duration: 0.4, ease: 'easeOut' };

  traverse(ast, {
    ObjectProperty(path) {
      if (path.node.key.name === 'transition' || path.node.key.value === 'transition') {
        const value = path.node.value;
        if (value.type === 'ObjectExpression') {
          transition = extractObjectValue(value);
        }
      }
    },
  });

  return transition;
}

/**
 * Extract object value from AST node
 */
function extractObjectValue(node) {
  if (!node) return null;

  switch (node.type) {
    case 'NumericLiteral':
      return node.value;
    case 'StringLiteral':
      return node.value;
    case 'BooleanLiteral':
      return node.value;
    case 'ArrayExpression':
      return node.elements.map(el => extractObjectValue(el));
    case 'ObjectExpression':
      const obj = {};
      for (const prop of node.properties) {
        const key = prop.key.name || prop.key.value;
        obj[key] = extractObjectValue(prop.value);
      }
      return obj;
    case 'UnaryExpression':
      if (node.operator === '-') {
        return -extractObjectValue(node.argument);
      }
      return null;
    case 'Identifier':
      // Handle references like Infinity
      if (node.name === 'Infinity') return 999999;
      return node.name;
    default:
      return null;
  }
}

/**
 * Extract element data from JSX attributes
 */
function extractElement(type, attributes, variants, transition) {
  const element = { type };
  const animationData = {};

  for (const attr of attributes) {
    if (attr.type !== 'JSXAttribute') continue;

    const name = attr.name.name;
    let value = null;

    if (attr.value) {
      if (attr.value.type === 'StringLiteral') {
        value = attr.value.value;
      } else if (attr.value.type === 'JSXExpressionContainer') {
        value = extractObjectValue(attr.value.expression);
      }
    }

    // SVG attributes
    if (['d', 'cx', 'cy', 'r', 'x', 'y', 'x1', 'y1', 'x2', 'y2', 'width', 'height', 'rx', 'ry', 'points'].includes(name)) {
      element[name] = value;
    }

    // Animation attributes
    if (name === 'variants' && typeof value === 'string' && variants[value]) {
      // Reference to variants object
      Object.assign(animationData, { variantsRef: value });
    }
  }

  // Determine animation from variants
  const animation = determineAnimation(variants, transition);
  if (animation) {
    element.animation = animation;
  }

  return element;
}

/**
 * Extract icon-level animation from SVG attributes
 */
function extractIconAnimation(attributes, variants, transition) {
  return determineAnimation(variants, transition);
}

/**
 * Determine animation type from variants
 */
function determineAnimation(variants, transition) {
  if (!variants || Object.keys(variants).length === 0) return null;

  const normal = variants.normal || variants.initial || {};
  const animate = variants.animate || variants.hover || {};

  const animation = {
    duration: Math.round((transition.duration || 0.4) * 1000),
    delay: Math.round((transition.delay || 0) * 1000),
    easing: mapEasing(transition.ease || transition.type || 'easeOut'),
  };

  // Detect animation type
  if ('pathLength' in animate || 'pathLength' in normal) {
    const from = Array.isArray(animate.pathLength) ? animate.pathLength[0] : (normal.pathLength ?? 0);
    const to = Array.isArray(animate.pathLength) ? animate.pathLength[1] : (animate.pathLength ?? 1);

    // Check for combined with opacity
    if ('opacity' in animate || 'opacity' in normal) {
      const opFrom = Array.isArray(animate.opacity) ? animate.opacity[0] : (normal.opacity ?? 0);
      const opTo = Array.isArray(animate.opacity) ? animate.opacity[1] : (animate.opacity ?? 1);

      return {
        type: 'combined',
        pathLength: { from, to },
        opacity: { from: opFrom, to: opTo },
        ...animation,
      };
    }

    return { type: 'pathLength', from, to, ...animation };
  }

  if ('opacity' in animate || 'opacity' in normal) {
    const from = Array.isArray(animate.opacity) ? animate.opacity[0] : (normal.opacity ?? 0);
    const to = Array.isArray(animate.opacity) ? animate.opacity[1] : (animate.opacity ?? 1);
    return { type: 'opacity', from, to, ...animation };
  }

  if ('rotate' in animate || 'rotate' in normal) {
    if (Array.isArray(animate.rotate)) {
      return { type: 'rotateKeyframe', keyframes: animate.rotate, origin: 'center', ...animation };
    }
    const from = normal.rotate ?? 0;
    const to = animate.rotate ?? 360;
    return { type: 'rotate', from, to, origin: 'center', ...animation };
  }

  if ('x' in animate || 'y' in animate || 'x' in normal || 'y' in normal) {
    if (Array.isArray(animate.x) || Array.isArray(animate.y)) {
      return {
        type: 'translateKeyframe',
        keyframesX: animate.x || [0],
        keyframesY: animate.y || [0],
        ...animation,
      };
    }
    return {
      type: 'translate',
      fromX: normal.x ?? 0,
      toX: animate.x ?? 0,
      fromY: normal.y ?? 0,
      toY: animate.y ?? 0,
      ...animation,
    };
  }

  if ('scale' in animate || 'scale' in normal) {
    const from = normal.scale ?? 1;
    const to = animate.scale ?? 1;
    return { type: 'scale', from, to, ...animation };
  }

  return null;
}

/**
 * Map framer-motion easing to Flutter curve name
 */
function mapEasing(ease) {
  if (typeof ease === 'string') {
    const mapping = {
      'linear': 'linear',
      'easeIn': 'easeIn',
      'easeOut': 'easeOut',
      'easeInOut': 'easeInOut',
      'circIn': 'easeInCirc',
      'circOut': 'easeOutCirc',
      'circInOut': 'easeInOutCirc',
      'backIn': 'easeInBack',
      'backOut': 'easeOutBack',
      'backInOut': 'easeInOutBack',
    };
    return mapping[ease] || 'easeOut';
  }

  // Spring physics - map to easeOut for now
  if (ease === 'spring') return 'easeOutBack';

  return 'easeOut';
}

/**
 * Write icon JSON to file
 */
function writeIconJson(iconData) {
  const filePath = path.join(ICONS_OUTPUT_DIR, `${iconData.name}.json`);
  fs.writeFileSync(filePath, JSON.stringify(iconData, null, 2));
}

/**
 * Write registry JSON
 */
function writeRegistry(iconNames) {
  const registry = {
    version: '1.0.0',
    updated_at: new Date().toISOString(),
    total: iconNames.length,
    icons: iconNames.sort(),
  };

  const filePath = path.join(OUTPUT_DIR, 'registry.json');
  fs.writeFileSync(filePath, JSON.stringify(registry, null, 2));
}

/**
 * Main sync function
 */
async function main() {
  console.log('flutter_lucide_animated sync');
  console.log('============================');
  console.log('');

  // Create output directories
  fs.mkdirSync(ICONS_OUTPUT_DIR, { recursive: true });

  // Fetch icon list
  let iconNames = await fetchIconList();

  if (LIMIT) {
    console.log(`Limiting to first ${LIMIT} icons (test mode)`);
    iconNames = iconNames.slice(0, LIMIT);
  }

  console.log('');
  console.log('Syncing icons...');

  const successfulIcons = [];
  const failedIcons = [];

  for (let i = 0; i < iconNames.length; i++) {
    const iconName = iconNames[i];
    const progress = `[${i + 1}/${iconNames.length}]`;

    try {
      process.stdout.write(`${progress} ${iconName}... `);

      const source = await fetchIconSource(iconName);
      const iconData = parseIconSource(iconName, source);

      if (iconData.elements.length > 0) {
        writeIconJson(iconData);
        successfulIcons.push(iconName);
        console.log('done');
      } else {
        console.log('skipped (no elements)');
        failedIcons.push(iconName);
      }

      // Rate limiting
      if (i % 10 === 9) {
        await new Promise(r => setTimeout(r, 100));
      }
    } catch (error) {
      console.log(`failed (${error.message})`);
      failedIcons.push(iconName);
    }
  }

  // Write registry
  console.log('');
  console.log('Writing registry...');
  writeRegistry(successfulIcons);

  // Summary
  console.log('');
  console.log('============================');
  console.log(`Synced: ${successfulIcons.length} icons`);
  if (failedIcons.length > 0) {
    console.log(`Failed: ${failedIcons.length} icons`);
  }
  console.log(`Output: ${OUTPUT_DIR}`);
}

main().catch(console.error);

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart' as lucide;
import 'package:google_fonts/google_fonts.dart';
import 'package:adaptive_screen_utils/adaptive_screen_utils.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucide Animated',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFf97316),
          surface: Color(0xFF09090B),
        ),
        textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const IconGallery(),
    );
  }
}

// All available icons
final List<(String, lucide.LucideAnimatedIconData)> _allIcons = [
  ('a_arrow_down', lucide.a_arrow_down),
  ('a_arrow_up', lucide.a_arrow_up),
  ('accessibility', lucide.accessibility),
  ('activity', lucide.activity),
  ('airplane', lucide.airplane),
  ('airplay', lucide.airplay),
  ('air_vent', lucide.air_vent),
  ('alarm_clock', lucide.alarm_clock),
  ('align_center', lucide.align_center),
  ('align_horizontal', lucide.align_horizontal),
  ('align_left', lucide.align_left),
  ('align_right', lucide.align_right),
  ('align_vertical', lucide.align_vertical),
  ('angry', lucide.angry),
  ('annoyed', lucide.annoyed),
  ('archive', lucide.archive),
  ('arrow_big_down', lucide.arrow_big_down),
  ('arrow_big_down_dash', lucide.arrow_big_down_dash),
  ('arrow_big_left', lucide.arrow_big_left),
  ('arrow_big_left_dash', lucide.arrow_big_left_dash),
  ('arrow_big_right', lucide.arrow_big_right),
  ('arrow_big_right_dash', lucide.arrow_big_right_dash),
  ('arrow_big_up', lucide.arrow_big_up),
  ('arrow_big_up_dash', lucide.arrow_big_up_dash),
  ('arrow_down', lucide.arrow_down),
  ('arrow_down_0_1', lucide.arrow_down_0_1),
  ('arrow_down_1_0', lucide.arrow_down_1_0),
  ('arrow_down_a_z', lucide.arrow_down_a_z),
  ('arrow_down_left', lucide.arrow_down_left),
  ('arrow_down_right', lucide.arrow_down_right),
  ('arrow_down_z_a', lucide.arrow_down_z_a),
  ('arrow_left', lucide.arrow_left),
  ('arrow_right', lucide.arrow_right),
  ('arrow_up', lucide.arrow_up),
  ('arrow_up_left', lucide.arrow_up_left),
  ('arrow_up_right', lucide.arrow_up_right),
  ('atom', lucide.atom),
  ('at_sign', lucide.at_sign),
  ('attach_file', lucide.attach_file),
  ('audio_lines', lucide.audio_lines),
  ('badge_alert', lucide.badge_alert),
  ('badge_percent', lucide.badge_percent),
  ('ban', lucide.ban),
  ('banana', lucide.banana),
  ('battery', lucide.battery),
  ('battery_charging', lucide.battery_charging),
  ('battery_full', lucide.battery_full),
  ('battery_low', lucide.battery_low),
  ('battery_medium', lucide.battery_medium),
  ('battery_plus', lucide.battery_plus),
  ('battery_warning', lucide.battery_warning),
  ('bell', lucide.bell),
  ('bell_electric', lucide.bell_electric),
  ('blocks', lucide.blocks),
  ('bluetooth', lucide.bluetooth),
  ('bluetooth_connected', lucide.bluetooth_connected),
  ('bluetooth_off', lucide.bluetooth_off),
  ('bluetooth_searching', lucide.bluetooth_searching),
  ('bold', lucide.bold),
  ('bone', lucide.bone),
  ('bookmark', lucide.bookmark),
  ('bookmark_check', lucide.bookmark_check),
  ('bookmark_minus', lucide.bookmark_minus),
  ('bookmark_plus', lucide.bookmark_plus),
  ('bookmark_x', lucide.bookmark_x),
  ('book_text', lucide.book_text),
  ('bot', lucide.bot),
  ('bot_message_square', lucide.bot_message_square),
  ('box', lucide.box),
  ('boxes', lucide.boxes),
  ('calendar_check', lucide.calendar_check),
  ('calendar_check_2', lucide.calendar_check_2),
  ('calendar_cog', lucide.calendar_cog),
  ('calendar_days', lucide.calendar_days),
  ('cart', lucide.cart),
  ('cast', lucide.cast),
  ('cctv', lucide.cctv),
  ('chart_bar_decreasing', lucide.chart_bar_decreasing),
  ('chart_bar_increasing', lucide.chart_bar_increasing),
  ('chart_column_decreasing', lucide.chart_column_decreasing),
  ('chart_column_increasing', lucide.chart_column_increasing),
  ('chart_line', lucide.chart_line),
  ('chart_no_axes_column_decreasing', lucide.chart_no_axes_column_decreasing),
  ('chart_no_axes_column_increasing', lucide.chart_no_axes_column_increasing),
  ('chart_pie', lucide.chart_pie),
  ('chart_scatter', lucide.chart_scatter),
  ('chart_spline', lucide.chart_spline),
  ('check', lucide.check),
  ('check_check', lucide.check_check),
  ('chevron_down', lucide.chevron_down),
  ('chevron_first', lucide.chevron_first),
  ('chevron_left', lucide.chevron_left),
  ('chevron_right', lucide.chevron_right),
  ('chevrons_down_up', lucide.chevrons_down_up),
  ('chevrons_left_right', lucide.chevrons_left_right),
  ('chevrons_right_left', lucide.chevrons_right_left),
  ('chevrons_up_down', lucide.chevrons_up_down),
  ('chevron_up', lucide.chevron_up),
  ('chrome', lucide.chrome),
  ('circle_check', lucide.circle_check),
  ('circle_chevron_down', lucide.circle_chevron_down),
  ('circle_chevron_left', lucide.circle_chevron_left),
  ('circle_chevron_right', lucide.circle_chevron_right),
  ('circle_chevron_up', lucide.circle_chevron_up),
  ('circle_dashed', lucide.circle_dashed),
  ('circle_dollar_sign', lucide.circle_dollar_sign),
  ('circle_help', lucide.circle_help),
  ('clap', lucide.clap),
  ('clipboard_check', lucide.clipboard_check),
  ('clock', lucide.clock),
  ('cloud_cog', lucide.cloud_cog),
  ('cloud_download', lucide.cloud_download),
  ('cloud_lightning', lucide.cloud_lightning),
  ('cloud_rain', lucide.cloud_rain),
  ('cloud_rain_wind', lucide.cloud_rain_wind),
  ('cloud_snow', lucide.cloud_snow),
  ('cloud_sun', lucide.cloud_sun),
  ('cloud_upload', lucide.cloud_upload),
  ('coffee', lucide.coffee),
  ('cog', lucide.cog),
  ('compass', lucide.compass),
  ('connect', lucide.connect),
  ('construction', lucide.construction),
  ('contrast', lucide.contrast),
  ('cooking_pot', lucide.cooking_pot),
  ('copy', lucide.copy),
  ('corner_down_left', lucide.corner_down_left),
  ('corner_down_right', lucide.corner_down_right),
  ('corner_left_down', lucide.corner_left_down),
  ('corner_left_up', lucide.corner_left_up),
  ('corner_right_down', lucide.corner_right_down),
  ('corner_right_up', lucide.corner_right_up),
  ('corner_up_left', lucide.corner_up_left),
  ('corner_up_right', lucide.corner_up_right),
  ('cpu', lucide.cpu),
  ('cursor_click', lucide.cursor_click),
  ('delete', lucide.delete),
  ('discord', lucide.discord),
  ('dollar_sign', lucide.dollar_sign),
  ('download', lucide.download),
  ('downvote', lucide.downvote),
  ('dribbble', lucide.dribbble),
  ('droplet', lucide.droplet),
  ('drum', lucide.drum),
  ('earth', lucide.earth),
  ('euro', lucide.euro),
  ('ev_charger', lucide.ev_charger),
  ('expand', lucide.expand),
  ('eye', lucide.eye),
  ('eye_off', lucide.eye_off),
  ('facebook', lucide.facebook),
  ('feather', lucide.feather),
  ('figma', lucide.figma),
  ('file_chart_line', lucide.file_chart_line),
  ('file_check', lucide.file_check),
  ('file_check_2', lucide.file_check_2),
  ('file_cog', lucide.file_cog),
  ('file_pen_line', lucide.file_pen_line),
  ('file_stack', lucide.file_stack),
  ('file_text', lucide.file_text),
  ('fingerprint', lucide.fingerprint),
  ('fish_symbol', lucide.fish_symbol),
  ('flame', lucide.flame),
  ('flask', lucide.flask),
  ('folder_archive', lucide.folder_archive),
  ('folder_check', lucide.folder_check),
  ('folder_clock', lucide.folder_clock),
  ('folder_code', lucide.folder_code),
  ('folder_cog', lucide.folder_cog),
  ('folder_dot', lucide.folder_dot),
  ('folder_down', lucide.folder_down),
  ('folder_git', lucide.folder_git),
  ('folder_git_2', lucide.folder_git_2),
  ('folder_heart', lucide.folder_heart),
  ('folder_input', lucide.folder_input),
  ('folder_kanban', lucide.folder_kanban),
  ('folder_key', lucide.folder_key),
  ('folder_lock', lucide.folder_lock),
  ('folder_minus', lucide.folder_minus),
  ('folder_open', lucide.folder_open),
  ('folder_output', lucide.folder_output),
  ('folder_plus', lucide.folder_plus),
  ('folder_root', lucide.folder_root),
  ('folders', lucide.folders),
  ('folder_sync', lucide.folder_sync),
  ('folder_tree', lucide.folder_tree),
  ('folder_up', lucide.folder_up),
  ('folder_x', lucide.folder_x),
  ('frame', lucide.frame),
  ('frown', lucide.frown),
  ('gallery_horizontal_end', lucide.gallery_horizontal_end),
  ('gallery_thumbnails', lucide.gallery_thumbnails),
  ('gallery_vertical_end', lucide.gallery_vertical_end),
  ('gauge', lucide.gauge),
  ('georgian_lari', lucide.georgian_lari),
  ('git_branch', lucide.git_branch),
  ('git_commit_horizontal', lucide.git_commit_horizontal),
  ('git_commit_vertical', lucide.git_commit_vertical),
  ('git_compare', lucide.git_compare),
  ('git_compare_arrows', lucide.git_compare_arrows),
  ('git_fork', lucide.git_fork),
  ('git_graph', lucide.git_graph),
  ('github', lucide.github),
  ('gitlab', lucide.gitlab),
  ('git_merge', lucide.git_merge),
  ('git_pull_request', lucide.git_pull_request),
  ('git_pull_request_closed', lucide.git_pull_request_closed),
  ('git_pull_request_create', lucide.git_pull_request_create),
  ('grip', lucide.grip),
  ('grip_horizontal', lucide.grip_horizontal),
  ('grip_vertical', lucide.grip_vertical),
  ('hand', lucide.hand),
  ('hand_coins', lucide.hand_coins),
  ('hand_fist', lucide.hand_fist),
  ('hand_grab', lucide.hand_grab),
  ('hand_heart', lucide.hand_heart),
  ('hand_helping', lucide.hand_helping),
  ('hand_metal', lucide.hand_metal),
  ('hard_drive_download', lucide.hard_drive_download),
  ('hard_drive_upload', lucide.hard_drive_upload),
  ('heart', lucide.heart),
  ('heart_handshake', lucide.heart_handshake),
  ('history', lucide.history),
  ('home', lucide.home),
  ('hourglass', lucide.hourglass),
  ('id_card', lucide.id_card),
  ('indian_rupee', lucide.indian_rupee),
  ('instagram', lucide.instagram),
  ('italic', lucide.italic),
  ('japanese_yen', lucide.japanese_yen),
  ('key', lucide.key),
  ('keyboard', lucide.keyboard),
  ('key_circle', lucide.key_circle),
  ('key_square', lucide.key_square),
  ('languages', lucide.languages),
  ('laptop_minimal_check', lucide.laptop_minimal_check),
  ('laugh', lucide.laugh),
  ('layers', lucide.layers),
  ('layout_panel_top', lucide.layout_panel_top),
  ('link', lucide.link),
  ('linkedin', lucide.linkedin),
  ('loader_pinwheel', lucide.loader_pinwheel),
  ('lock', lucide.lock),
  ('lock_keyhole', lucide.lock_keyhole),
  ('lock_keyhole_open', lucide.lock_keyhole_open),
  ('lock_open', lucide.lock_open),
  ('logout', lucide.logout),
  ('mail_check', lucide.mail_check),
  ('map_pin', lucide.map_pin),
  ('map_pin_check', lucide.map_pin_check),
  ('map_pin_check_inside', lucide.map_pin_check_inside),
  ('map_pin_house', lucide.map_pin_house),
  ('map_pin_minus', lucide.map_pin_minus),
  ('map_pin_minus_inside', lucide.map_pin_minus_inside),
  ('map_pin_off', lucide.map_pin_off),
  ('map_pin_plus', lucide.map_pin_plus),
  ('map_pin_plus_inside', lucide.map_pin_plus_inside),
  ('map_pin_x_inside', lucide.map_pin_x_inside),
  ('maximize', lucide.maximize),
  ('maximize_2', lucide.maximize_2),
  ('meh', lucide.meh),
  ('menu', lucide.menu),
  ('message_circle', lucide.message_circle),
  ('message_circle_dashed', lucide.message_circle_dashed),
  ('message_circle_more', lucide.message_circle_more),
  ('message_square', lucide.message_square),
  ('message_square_dashed', lucide.message_square_dashed),
  ('message_square_more', lucide.message_square_more),
  ('mic', lucide.mic),
  ('mic_off', lucide.mic_off),
  ('minimize', lucide.minimize),
  ('monitor_check', lucide.monitor_check),
  ('moon', lucide.moon),
  ('nfc', lucide.nfc),
  ('panel_left_close', lucide.panel_left_close),
  ('panel_left_open', lucide.panel_left_open),
  ('panel_right_open', lucide.panel_right_open),
  ('party_popper', lucide.party_popper),
  ('pause', lucide.pause),
  ('pen_tool', lucide.pen_tool),
  ('philippine_peso', lucide.philippine_peso),
  ('play', lucide.play),
  ('plug_zap', lucide.plug_zap),
  ('plus', lucide.plus),
  ('pound_sterling', lucide.pound_sterling),
  ('rabbit', lucide.rabbit),
  ('radio', lucide.radio),
  ('radio_tower', lucide.radio_tower),
  ('redo', lucide.redo),
  ('redo_dot', lucide.redo_dot),
  ('refresh_ccw', lucide.refresh_ccw),
  ('refresh_ccw_dot', lucide.refresh_ccw_dot),
  ('refresh_cw', lucide.refresh_cw),
  ('refresh_cw_off', lucide.refresh_cw_off),
  ('rocket', lucide.rocket),
  ('rocking_chair', lucide.rocking_chair),
  ('roller_coaster', lucide.roller_coaster),
  ('rotate_ccw', lucide.rotate_ccw),
  ('rotate_cw', lucide.rotate_cw),
  ('route', lucide.route),
  ('russian_ruble', lucide.russian_ruble),
  ('saudi_riyal', lucide.saudi_riyal),
  ('scan_face', lucide.scan_face),
  ('scan_text', lucide.scan_text),
  ('search', lucide.search),
  ('settings', lucide.settings),
  ('shield_check', lucide.shield_check),
  ('ship', lucide.ship),
  ('shower_head', lucide.shower_head),
  ('shrink', lucide.shrink),
  ('sliders_horizontal', lucide.sliders_horizontal),
  ('smartphone_charging', lucide.smartphone_charging),
  ('smartphone_nfc', lucide.smartphone_nfc),
  ('smile', lucide.smile),
  ('smile_plus', lucide.smile_plus),
  ('snowflake', lucide.snowflake),
  ('sparkles', lucide.sparkles),
  ('square_activity', lucide.square_activity),
  ('square_arrow_down', lucide.square_arrow_down),
  ('square_arrow_left', lucide.square_arrow_left),
  ('square_arrow_right', lucide.square_arrow_right),
  ('square_arrow_up', lucide.square_arrow_up),
  ('square_chevron_down', lucide.square_chevron_down),
  ('square_chevron_left', lucide.square_chevron_left),
  ('square_chevron_right', lucide.square_chevron_right),
  ('square_chevron_up', lucide.square_chevron_up),
  ('square_pen', lucide.square_pen),
  ('square_stack', lucide.square_stack),
  ('stethoscope', lucide.stethoscope),
  ('sun', lucide.sun),
  ('sun_dim', lucide.sun_dim),
  ('sun_medium', lucide.sun_medium),
  ('sun_moon', lucide.sun_moon),
  ('sunset', lucide.sunset),
  ('swiss_franc', lucide.swiss_franc),
  ('syringe', lucide.syringe),
  ('telescope', lucide.telescope),
  ('terminal', lucide.terminal),
  ('thermometer', lucide.thermometer),
  ('timer', lucide.timer),
  ('tornado', lucide.tornado),
  ('train_track', lucide.train_track),
  ('trending_down', lucide.trending_down),
  ('trending_up', lucide.trending_up),
  ('trending_up_down', lucide.trending_up_down),
  ('truck', lucide.truck),
  ('turkish_lira', lucide.turkish_lira),
  ('twitch', lucide.twitch),
  ('twitter', lucide.twitter),
  ('underline', lucide.underline),
  ('undo', lucide.undo),
  ('undo_dot', lucide.undo_dot),
  ('upload', lucide.upload),
  ('upvote', lucide.upvote),
  ('user', lucide.user),
  ('user_check', lucide.user_check),
  ('user_round_check', lucide.user_round_check),
  ('user_round_plus', lucide.user_round_plus),
  ('users', lucide.users),
  ('vibrate', lucide.vibrate),
  ('volume', lucide.volume),
  ('washing_machine', lucide.washing_machine),
  ('waves', lucide.waves),
  ('waves_ladder', lucide.waves_ladder),
  ('waypoints', lucide.waypoints),
  ('webhook', lucide.webhook),
  ('wifi', lucide.wifi),
  ('wind', lucide.wind),
  ('wind_arrow_down', lucide.wind_arrow_down),
  ('workflow', lucide.workflow),
  ('wrench', lucide.wrench),
  ('x', lucide.x),
  ('youtube', lucide.youtube),
  ('zap', lucide.zap),
  ('zap_off', lucide.zap_off),
];

class IconGallery extends StatefulWidget {
  const IconGallery({super.key});

  @override
  State<IconGallery> createState() => _IconGalleryState();
}

class _IconGalleryState extends State<IconGallery> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<(String, lucide.LucideAnimatedIconData)> get _filteredIcons {
    if (_searchQuery.isEmpty) return _allIcons;
    final query = _searchQuery.toLowerCase();
    return _allIcons
        .where((icon) => icon.$1.toLowerCase().contains(query))
        .toList();
  }

  void _copyToClipboard(String name) {
    Clipboard.setData(ClipboardData(text: name));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$name" to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF262626),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.compact;
    final tablet = context.medium;
    final desktop = context.expanded;

    // Responsive values
    final crossAxisCount = mobile ? 2 : (tablet ? 4 : 6);
    final padding = mobile ? 12.0 : 16.0;
    final titleFontSize = mobile ? 24.0 : (tablet ? 32.0 : 40.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter-lucide-animated'),
        centerTitle: false,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        actions: [
          IconButton(
            onPressed: () async {
              final uri = Uri.parse(
                "https://github.com/ravikovind/flutter_lucide_animated",
              );
              await launchUrl(uri);
            },
            icon: lucide.LucideAnimatedIcon(
              icon: lucide.github,
              trigger: lucide.AnimationTrigger.onTap,
            ),
          ),
          IconButton(
            onPressed: () async {
              final uri = Uri.parse("https://lucide-animated.com");
              await launchUrl(uri);
            },
            icon: lucide.LucideAnimatedIcon(
              icon: lucide.link,
              trigger: lucide.AnimationTrigger.onTap,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          // Hero Section
          Padding(
            padding: EdgeInsets.symmetric(vertical: mobile ? 24 : 40),
            child: Column(
              children: [
                Text(
                  'Beautifully crafted',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'animated icons',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFf97316),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${_allIcons.length}+ smooth animations powered by Flutter',
                  style: TextStyle(
                    fontSize: mobile ? 14 : 16,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Install command
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'flutter pub add flutter_lucide_animated',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: mobile ? 11 : 14,
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        color: Colors.grey[400],
                        onPressed: () => _copyToClipboard(
                          'flutter pub add flutter_lucide_animated',
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tap or Hover to animate!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.4,
                    wordSpacing: 2.4
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Search
          Container(
            margin: EdgeInsets.only(bottom: padding),
            constraints: BoxConstraints(
              maxWidth: mobile ? double.infinity : 500,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search ${_allIcons.length} icons...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                filled: true,
                fillColor: const Color(0xFF18181B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF27272A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF27272A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFf97316)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // Icon Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: padding,
              crossAxisSpacing: padding,
              childAspectRatio: desktop ? 1.0 : 0.85,
            ),
            itemCount: _filteredIcons.length,
            itemBuilder: (context, index) {
              final (name, iconData) = _filteredIcons[index];
              return _IconCard(
                name: name,
                iconData: iconData,
                useHoverTrigger: desktop,
                onTap: () => _copyToClipboard(name),
              );
            },
          ),

          // Footer
          Padding(
            padding: EdgeInsets.symmetric(vertical: mobile ? 32 : 48),
            child: Column(
              children: [
                const Divider(color: Color(0xFF27272A)),
                const SizedBox(height: 24),
                Text(
                  'Made with Flutter by Ravi Kovind',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final uri = Uri.parse('https://ravikovind.github.io/');
                    await launchUrl(uri);
                  },
                  child: Text(
                    'Available for hire!',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFf97316),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCard extends StatefulWidget {
  final String name;
  final lucide.LucideAnimatedIconData iconData;
  final bool useHoverTrigger;
  final VoidCallback onTap;

  const _IconCard({
    required this.name,
    required this.iconData,
    required this.useHoverTrigger,
    required this.onTap,
  });

  @override
  State<_IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<_IconCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF18181B);
    const hoverColor = Color(0xFF27272A);
    const borderColor = Color(0xFF27272A);
    const hoverBorderColor = Color(0xFF3F3F46);
    const iconColor = Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? hoverBorderColor : borderColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              lucide.LucideAnimatedIcon(
                icon: widget.iconData,
                size: 48,
                color: _isHovered ? const Color(0xFFf97316) : iconColor,
                trigger: widget.useHoverTrigger
                    ? lucide.AnimationTrigger.onHover
                    : lucide.AnimationTrigger.onTap,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.name.replaceAll('_', '-'),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: _isHovered
                        ? const Color(0xFFf97316)
                        : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

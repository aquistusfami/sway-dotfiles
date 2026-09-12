//
/* You may copy+paste this file and use it as it is.
 *
 * If you make changes to your about:config while the program is running, the
 * changes will be overwritten by the user.js when the application restarts.
 *
 * To make lasting changes to preferences, you will have to edit the user.js.
 */

/****************************************************************************
 * Betterfox                                                                *
 * "Ad meliora"                                                             *
 * version: 152                                                             *
 * url: https://github.com/yokoffing/Betterfox                              *
****************************************************************************/

/****************************************************************************
 * SECTION: FASTFOX                                                         *
****************************************************************************/
/** GENERAL ***/
user_pref("gfx.content.skia-font-cache-size", 20);
user_pref("content.notify.interval", 100000);

/** GFX ***/
user_pref("gfx.canvas.accelerated.cache-size", 512);

/** JS ***/
user_pref("javascript.options.baselinejit.threshold", 50);

/** MEDIA CACHE ***/
user_pref("media.cache_readahead_limit", 3600);
user_pref("media.cache_resume_threshold", 1800);

/** IMAGE CACHE ***/
user_pref("image.mem.decode_bytes_at_a_time", 32768);

/** NETWORKING ***/
user_pref("network.buffer.cache.size", 65535);
user_pref("network.buffer.cache.count", 48);
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.request.max-start-delay", 5);
user_pref("network.dnsCacheExpiration", 3600);
// Fix slow loading on networks without IPv6 WAN (bypasses AAAA queries & IPv6 timeouts)
user_pref("network.dns.disableIPv6", true);
// Disable HTTP/3 (QUIC/UDP) to avoid stalled handshakes from ISP UDP throttling
user_pref("network.http.http3.enable", false);

/****************************************************************************
 * SECTION: SECUREFOX                                                       *
****************************************************************************/
/** TRACKING PROTECTION ***/
user_pref("browser.contentblocking.category", "strict");
user_pref("browser.download.start_downloads_in_tmp_dir", true);
user_pref("browser.uitour.enabled", false);
user_pref("privacy.globalprivacycontrol.enabled", true);

/** OCSP & CERTS / HPKP ***/
user_pref("security.OCSP.enabled", 0);
user_pref("privacy.antitracking.isolateContentScriptResources", true);
user_pref("security.csp.reporting.enabled", false);

/** SSL / TLS ***/
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("security.tls.enable_0rtt_data", false);

/** DISK AVOIDANCE ***/
user_pref("browser.cache.disk.enable", false);
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
user_pref("media.memory_cache_max_size", 65536);
user_pref("browser.sessionstore.interval", 60000);

/** SHUTDOWN & SANITIZING ***/
user_pref("privacy.history.custom", true);

/** SPECULATIVE LOADING & PREFETCH ***/
user_pref("network.http.speculative-parallel-limit", 6);
user_pref("network.dns.disablePrefetch", false);
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("browser.urlbar.speculativeConnect.enabled", true);
user_pref("browser.places.speculativeConnect.enabled", false);
user_pref("network.prefetch-next", true);

/** SEARCH / URL BAR ***/
user_pref("browser.urlbar.trimHttps", true);
user_pref("browser.urlbar.untrimOnUserInteraction.featureGate", true);
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.groupLabels.enabled", false);
user_pref("browser.formfill.enable", false);
user_pref("network.IDN_show_punycode", true);

/** HTTPS-ONLY MODE ***/
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_error_page_user_suggestions", true);

/** PASSWORDS ***/
user_pref("signon.formlessCapture.enabled", false);
user_pref("signon.privateBrowsingCapture.enabled", false);
user_pref("network.auth.subresource-http-auth-allow", 1);
user_pref("editor.truncate_user_pastes", false);

/** EXTENSIONS ***/
user_pref("extensions.enabledScopes", 5);

/** HEADERS / REFERERS ***/
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

/** CONTAINERS ***/
user_pref("privacy.userContext.ui.enabled", true);

/** VARIOUS ***/
user_pref("pdfjs.enableScripting", false);

/** SAFE BROWSING ***/
user_pref("browser.safebrowsing.downloads.remote.enabled", false);

/** MOZILLA ***/
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("geo.provider.network.url", "https://beacondb.net/v1/geolocate");
user_pref("browser.search.update", false);
user_pref("permissions.manager.defaultsUrl", "");
user_pref("extensions.getAddons.cache.enabled", false);

/** TELEMETRY ***/
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("datareporting.usage.uploadEnabled", false);

/** EXPERIMENTS ***/
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");

/** CRASH REPORTS ***/
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);

/****************************************************************************
 * SECTION: PESKYFOX                                                        *
****************************************************************************/
/** MOZILLA UI ***/
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.profiles.enabled", false);

/** THEME ADJUSTMENTS ***/
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.privateWindowSeparation.enabled", false); // WINDOWS

/** AI ***/
user_pref("browser.ai.control.default", "blocked");
user_pref("browser.ml.enable", false);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.ml.linkPreview.enabled", false);

/** FULLSCREEN NOTICE ***/
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.timeout", 0);

/** URL BAR ***/
user_pref("browser.urlbar.trending.featureGate", false);

/** NEW TAB PAGE ***/
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);

/** DOWNLOADS ***/
user_pref("browser.download.manager.addToRecentDocs", false);

/** PDF ***/
user_pref("browser.download.open_pdf_attachments_inline", true);

/** TAB BEHAVIOR ***/
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("findbar.highlightAll", true);


/****************************************************************************
 * SECTION: SMOOTHFOX (Sharpen Scrolling for 60Hz Display)                  *
****************************************************************************/
user_pref("apz.overscroll.enabled", true);
user_pref("general.smoothScroll", true);
user_pref("mousewheel.min_line_scroll_amount", 10);
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 80);
user_pref("general.smoothScroll.currentVelocityWeighting", "0.15");
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6");

/****************************************************************************
 * START: MY OVERRIDES - RAM USAGE OPTIMIZATIONS                            *
****************************************************************************/
// Limit content processes (balanced for 8-core/16-thread AMD Ryzen)
user_pref("dom.ipc.processCount.webIsolated", 8);
user_pref("dom.ipc.processCount", 8);

// Back-Forward Cache (bfcache): allow instant back/forward navigation
user_pref("browser.sessionhistory.max_total_viewers", 4);
// Tab history navigation entries (default 50 -> 25)
user_pref("browser.sessionhistory.max_entries", 25);

// Memory & Disk Cache optimization for 32GB RAM & NVMe SSD:
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.disk.capacity", 1048576); // 1 GB NVMe disk cache (avoids re-downloading assets)
user_pref("browser.cache.disk.smart_size.enabled", false);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", 524288); // 512 MB in-memory cache
user_pref("browser.cache.memory.max_entry_size", 32768); // 32 MB per object cap (accommodates modern JS bundles)

// Proactive Tab Unloading on memory constraints
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.tabs.min_inactive_duration_before_unload", 600000); // 10 minutes
user_pref("browser.low_commit_space_threshold_mb", 2048);

// Limit closed tab undo history retained in RAM
user_pref("browser.sessionstore.max_tabs_undo", 8);
user_pref("browser.sessionstore.max_windows_undo", 2);
user_pref("browser.sessionstore.interval", 120000);

// Image and Media RAM footprint
user_pref("image.mem.surfacecache.max_size_kb", 524288); // 512MB max for decoded image surfaces
user_pref("image.mem.surfacecache.discard_factor", 1);
user_pref("media.memory_cache_max_size", 131072); // 128MB media buffer

// Disable Accessibility service overhead (~60-100MB RAM)
user_pref("accessibility.force_disabled", 1);

// Garbage Collection responsiveness & memory freeing
user_pref("javascript.options.mem.gc_incremental_slice", 10);
user_pref("javascript.options.mem.high_water_mark", 128);

/****************************************************************************
 * START: MY OVERRIDES - MINIMAL STYLE & ACID DARK INTEGRATION              *
****************************************************************************/
// Enable custom userChrome.css / userContent.css support
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1); // Compact density
user_pref("svg.context-properties.content.enabled", true);
user_pref("widget.non-native-theme.scrollbar.style", 3); // Thin scrollbar
user_pref("layout.css.color-scheme.content", 1); // Dark content pages by default
user_pref("browser.in-content.dark-mode", true);
user_pref("ui.systemUsesDarkTheme", 1);

// Hide titlebar & use client-side decorations
user_pref("browser.tabs.inTitlebar", 1);

/****************************************************************************
 * END: BETTERFOX + RAM & MINIMAL TUNING                                    *
****************************************************************************/
user_pref("browser.startup.page", 3);
user_pref("browser.profiles.enabled", false);

// High-quality modern fonts for web content (Inter Variable)
user_pref("font.default.x-western", "sans-serif");
user_pref("font.default.vi", "sans-serif");
user_pref("font.name.sans-serif.x-western", "Inter Variable");
user_pref("font.name.sans-serif.vi", "Inter Variable");
user_pref("font.name.monospace.x-western", "Iosevka");
user_pref("font.name.monospace.vi", "Iosevka");

/****************************************************************************
 * SECTION: HARDWARE ACCELERATION & WAYLAND (ThinkPad P14s Gen 5 AMD)        *
 ****************************************************************************/
// AMD Radeon 780M / VCN 4.0 Hardware Video Decoding (AV1, VP9, H.264, HEVC)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);
user_pref("media.av1.enabled", true);
user_pref("gfx.webrender.all", true);

// Wayland fractional scaling & crisp rendering
user_pref("widget.wayland.fractional-scale.enabled", true);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("apz.gtk.kinetic_scroll.enabled", true);

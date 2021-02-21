void debug(String message) => const bool.fromEnvironment('dev.plugfox.pager.debug') ? print(message) : null;

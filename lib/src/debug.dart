// ignore_for_file: avoid_print
void debug(String message) =>
    const bool.fromEnvironment('dev.plugfox.pager.debug')
        ? print(message)
        : null;

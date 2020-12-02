class Fn {
  static final dynamic log = _Log();
}

class _Log {
  @override
  noSuchMethod(Invocation invocation) {
    if (invocation.positionalArguments.length > 0) print("CUSTOM_LOG ::> ${invocation.positionalArguments}");
    if (invocation.namedArguments.isNotEmpty)
      for (final arg in invocation.namedArguments.keys) {
        print("$arg ::>  ${invocation.namedArguments[arg]}");
      }
    return null;
  }
}

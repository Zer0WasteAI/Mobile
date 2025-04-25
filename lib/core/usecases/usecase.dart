/// Abstract class for a Use Case
abstract class UseCase<Type, Params> {
  /// Call method to execute the use case
  Future<Type> call(Params params);
}

/// Class for use cases that don't require parameters
class NoParams {
  /// Constructor
  const NoParams();
}
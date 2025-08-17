// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getUserInfoOnlineHash() => r'46b4697302149f977a698e06fc6744969efd0ab8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [getUserInfoOnline].
@ProviderFor(getUserInfoOnline)
const getUserInfoOnlineProvider = GetUserInfoOnlineFamily();

/// See also [getUserInfoOnline].
class GetUserInfoOnlineFamily extends Family<AsyncValue<UserInfoModel>> {
  /// See also [getUserInfoOnline].
  const GetUserInfoOnlineFamily();

  /// See also [getUserInfoOnline].
  GetUserInfoOnlineProvider call(
    String userId,
  ) {
    return GetUserInfoOnlineProvider(
      userId,
    );
  }

  @override
  GetUserInfoOnlineProvider getProviderOverride(
    covariant GetUserInfoOnlineProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getUserInfoOnlineProvider';
}

/// See also [getUserInfoOnline].
class GetUserInfoOnlineProvider
    extends AutoDisposeFutureProvider<UserInfoModel> {
  /// See also [getUserInfoOnline].
  GetUserInfoOnlineProvider(
    String userId,
  ) : this._internal(
          (ref) => getUserInfoOnline(
            ref as GetUserInfoOnlineRef,
            userId,
          ),
          from: getUserInfoOnlineProvider,
          name: r'getUserInfoOnlineProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getUserInfoOnlineHash,
          dependencies: GetUserInfoOnlineFamily._dependencies,
          allTransitiveDependencies:
              GetUserInfoOnlineFamily._allTransitiveDependencies,
          userId: userId,
        );

  GetUserInfoOnlineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<UserInfoModel> Function(GetUserInfoOnlineRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetUserInfoOnlineProvider._internal(
        (ref) => create(ref as GetUserInfoOnlineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserInfoModel> createElement() {
    return _GetUserInfoOnlineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetUserInfoOnlineProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetUserInfoOnlineRef on AutoDisposeFutureProviderRef<UserInfoModel> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _GetUserInfoOnlineProviderElement
    extends AutoDisposeFutureProviderElement<UserInfoModel>
    with GetUserInfoOnlineRef {
  _GetUserInfoOnlineProviderElement(super.provider);

  @override
  String get userId => (origin as GetUserInfoOnlineProvider).userId;
}

String _$authViewModelHash() => r'88f492198eb85b9f0336368121e49978256a4686';

/// See also [AuthViewModel].
@ProviderFor(AuthViewModel)
final authViewModelProvider =
    AutoDisposeNotifierProvider<AuthViewModel, AsyncValue<UserModel>?>.internal(
  AuthViewModel.new,
  name: r'authViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthViewModel = AutoDisposeNotifier<AsyncValue<UserModel>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

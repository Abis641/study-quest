@override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    // Ensure user document exists; create if not
    final userService = ref.read(userServiceProvider);
    final existing = await userService.getUser(uid);
    if (existing == null) {
      // New user from social auth or just registered
      // Redirect to profile setup
      if (mounted) context.go(AppRoutes.profileSetup);
    }
  }

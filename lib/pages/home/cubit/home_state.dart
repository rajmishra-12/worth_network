part of 'home_cubit.dart';

enum HomeFeedTab { forYou, following }

class HomeState extends Equatable {
  final HomeFeedTab currentTab;

  // For You Feed State
  final List<ActionModel> actions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreForYou;
  final DocumentSnapshot? forYouLastDoc;
  final String? forYouError;

  // Following Feed State
  final List<ActionModel> followingActions;
  final bool isFollowingLoading;
  final bool isFollowingLoadingMore;
  final bool hasMoreFollowing;
  final DocumentSnapshot? followingLastDoc;
  final String? followingError;
  final bool isFollowingNobody;

  final int unreadCount;

  const HomeState({
    this.currentTab = HomeFeedTab.forYou,
    this.actions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreForYou = true,
    this.forYouLastDoc,
    this.forYouError,
    this.followingActions = const [],
    this.isFollowingLoading = false,
    this.isFollowingLoadingMore = false,
    this.hasMoreFollowing = true,
    this.followingLastDoc,
    this.followingError,
    this.isFollowingNobody = false,
    this.unreadCount = 3,
  });

  HomeState copyWith({
    HomeFeedTab? currentTab,
    List<ActionModel>? actions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreForYou,
    DocumentSnapshot? forYouLastDoc,
    String? forYouError,
    List<ActionModel>? followingActions,
    bool? isFollowingLoading,
    bool? isFollowingLoadingMore,
    bool? hasMoreFollowing,
    DocumentSnapshot? followingLastDoc,
    String? followingError,
    bool? isFollowingNobody,
    int? unreadCount,
  }) {
    return HomeState(
      currentTab: currentTab ?? this.currentTab,
      actions: actions ?? this.actions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreForYou: hasMoreForYou ?? this.hasMoreForYou,
      forYouLastDoc: forYouLastDoc ?? this.forYouLastDoc,
      forYouError: forYouError,
      followingActions: followingActions ?? this.followingActions,
      isFollowingLoading: isFollowingLoading ?? this.isFollowingLoading,
      isFollowingLoadingMore: isFollowingLoadingMore ?? this.isFollowingLoadingMore,
      hasMoreFollowing: hasMoreFollowing ?? this.hasMoreFollowing,
      followingLastDoc: followingLastDoc ?? this.followingLastDoc,
      followingError: followingError,
      isFollowingNobody: isFollowingNobody ?? this.isFollowingNobody,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        currentTab,
        actions,
        isLoading,
        isLoadingMore,
        hasMoreForYou,
        forYouLastDoc,
        forYouError,
        followingActions,
        isFollowingLoading,
        isFollowingLoadingMore,
        hasMoreFollowing,
        followingLastDoc,
        followingError,
        isFollowingNobody,
        unreadCount,
      ];
}
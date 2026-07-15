class LeaderboardResponse {
  final Leaderboard leaderboard;
  final List<Score> scores;
  final String? nextPage;

  LeaderboardResponse({
    required this.leaderboard,
    required this.scores,
    this.nextPage,
  });

  factory LeaderboardResponse.fromMap(Map<String, dynamic> map) {
    return LeaderboardResponse(
      leaderboard: Leaderboard.fromMap(map['leaderboard'] as Map<String, dynamic>? ?? {}),
      scores: (map['scores'] as List<dynamic>? ?? []).map((e) => Score.fromMap(e as Map<String, dynamic>)).toList(),
      nextPage: map['nextPage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leaderboard': leaderboard.toMap(),
      'scores': scores.map((e) => e.toMap()).toList(),
      'nextPage': nextPage,
    };
  }

  @override
  String toString() {
    return 'LeaderboardResponse(leaderboard: $leaderboard, scores: $scores, nextPage: $nextPage)';
  }
}

class Leaderboard {
  final String id;
  final String name;

  Leaderboard({
    required this.id,
    required this.name,
  });

  factory Leaderboard.fromMap(Map<String, dynamic> map) {
    return Leaderboard(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Leaderboard(id: $id, name: $name)';
  }
}

class Score {
  final int rank;
  final String rankDisplay;
  final int score;
  final String scoreDisplay;
  final String playerId;
  final String playerName;
  final String playerAvatar;

  Score({
    required this.rank,
    required this.rankDisplay,
    required this.score,
    required this.scoreDisplay,
    required this.playerId,
    required this.playerName,
    required this.playerAvatar,
  });

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      rank: map['rank'] as int? ?? 0,
      rankDisplay: map['rankDisplay'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      scoreDisplay: map['scoreDisplay'] as String? ?? '',
      playerId: map['playerId'] as String? ?? '',
      playerName: map['playerName'] as String? ?? '',
      playerAvatar: map['playerAvatar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'rankDisplay': rankDisplay,
      'score': score,
      'scoreDisplay': scoreDisplay,
      'playerId': playerId,
      'playerName': playerName,
      'playerAvatar': playerAvatar,
    };
  }

  @override
  String toString() {
    return 'Score(rank: $rank, rankDisplay: $rankDisplay, score: $score, scoreDisplay: $scoreDisplay, playerId: $playerId, playerName: $playerName, playerAvatar: $playerAvatar)';
  }
}

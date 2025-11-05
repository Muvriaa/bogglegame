import 'dart:io';
import 'dart:convert';
import 'dart:math';

class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEndOfWord = false;
}

class Trie {
  TrieNode root = TrieNode();

  void insert(String word) {
    TrieNode node = root;
    for (int i = 0; i < word.length; i++) {
      String c = word[i];
      node.children.putIfAbsent(c, () => TrieNode());
      node = node.children[c]!;
    }
    node.isEndOfWord = true;
  }

  bool search(String word) {
    TrieNode node = root;
    for (int i = 0; i < word.length; i++) {
      String c = word[i];
      if (!node.children.containsKey(c)) return false;
      node = node.children[c]!;
    }
    return node.isEndOfWord;
  }

  bool isPrefix(String prefix) {
    TrieNode node = root;
    for (int i = 0; i < prefix.length; i++) {
      String c = prefix[i];
      if (!node.children.containsKey(c)) return false;
      node = node.children[c]!;
    }
    return true;
  }
}


const int N = 6;
final List<List<String>> grid = List.generate(
    N,
    (_) => List.generate(
        N,
        (_) => String.fromCharCode(Random().nextInt(32) + 1072) // а-я
    )
);

final Set<String> foundWords = {};
late Trie trie;

final List<List<int>> dirs = [
  [-1, -1], [-1, 0], [-1, 1],
  [0, -1],          [0, 1],
  [1, -1], [1, 0],  [1, 1]
];

void dfs(int r, int c, Set<String> visited, String current) {
  current += grid[r][c];
  visited.add("$r,$c");

  if (!trie.isPrefix(current)) {
    visited.remove("$r,$c");
    return;
  }

  if (current.length >= 2 && trie.search(current)) {
    foundWords.add(current);
  }

  for (var d in dirs) {
    int nr = r + d[0];
    int nc = c + d[1];
    if (nr >= 0 && nr < N && nc >= 0 && nc < N && !visited.contains("$nr,$nc")) {
      dfs(nr, nc, visited, current);
    }
  }

  visited.remove("$r,$c");
}


void main() {
  trie = Trie();
  final file = File('russian_10000.txt');
  final words = file.readAsLinesSync(encoding: utf8);

  for (var w in words) {
    if (w.trim().isNotEmpty) {
      trie.insert(w.trim().toLowerCase());
    }
  }

  print("✅ Loaded ${words.length} Russian words into Trie");

  print("\n🎲 Boggle Grid:");
  for (var row in grid) {
    print(row.join(" "));
  }

  for (int r = 0; r < N; r++) {
    for (int c = 0; c < N; c++) {
      dfs(r, c, {}, '');
    }
  }

  print("\n📌 Found ${foundWords.length} words:");
  for (var w in foundWords.take(50)) {
    print(w);
  }
}


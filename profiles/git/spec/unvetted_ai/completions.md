<!--[>] 🤖🤖 -->
Feature: git checkout branch completion in recency order

Scenario: branch completion lists most recently committed-to branches first
  Status: implemented
  Given an interactive shell in a git repository with local and remote-tracking branches
  When I complete a branch argument, e.g. `git checkout <TAB>`, `git switch <TAB>`, `git branch -d <TAB>`, `git branch -u <TAB>`, `git push origin <TAB>`, `git log <TAB>`
  Then all branches are sorted by commit recency (committerdate), most recent first, in every group
  And the order matches `git for-each-ref --sort=-committerdate refs/heads` (refs/remotes for remote groups)
  And HEAD, FETCH_HEAD, ORIG_HEAD, MERGE_HEAD appear at the top of the local group
<!--[<] 🤖🤖 -->

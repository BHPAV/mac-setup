# Powerlevel10k Terminal Theme Examples

## Basic Prompt Structure

```
╭─  ~/Projects/my-app  main  ✓  node  v20.11.0  10:42:15
╰─❯ 
```

## What Each Segment Means:

### 1. Directory Path
```
~/Projects/my-app
```
- Shows current directory with `~` for home
- Truncates long paths intelligently
- Color changes based on write permissions

### 2. Git Information
```
 main  ✓
```
- Branch name (main)
- Status indicators:
  - `✓` = Clean working tree
  - `✗` = Uncommitted changes
  - `⇡` = Commits to push
  - `⇣` = Commits to pull
  - `⇠` = Behind remote
  - `*` = Dirty (modified files)
  - `+` = Staged changes

### 3. Context Information
```
 node  v20.11.0
```
- Shows active programming language versions
- Python virtual environments
- Ruby versions
- Node.js versions
- Docker contexts
- Kubernetes contexts

### 4. Time
```
10:42:15
```
- Optional timestamp
- Can show execution time of last command

## Real-World Examples:

### Clean Git Repository
```
╭─  ~/Projects/website  main  ✓  14:23:01
╰─❯ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

### Dirty Git Repository with Changes
```
╭─  ~/Projects/api  feature/auth  ✗ +2 ~1 -0 !  14:25:33
╰─❯ 
```
- On `feature/auth` branch
- 2 new files (+2)
- 1 modified file (~1)
- 0 deleted files (-0)
- Has untracked files (!)

### Python Virtual Environment Active
```
╭─  ~/Projects/ml-model  main  (venv)  python  3.11.7  14:27:45
╰─❯ 
```

### Failed Command (Red Arrow)
```
╭─  ~/Projects/app  main  ✓  14:28:12
╰─❯ npm test
... tests fail ...
╭─  ~/Projects/app  main  ✓  ✘ 1  14:28:45
╰─❯ 
```
- Red `✘ 1` shows last command failed with exit code 1

### SSH Connection
```
╭─  user@production-server  /var/www/app  14:30:22
╰─❯ 
```

### Docker Context Active
```
╭─  ~/DevOps/k8s  main  ✓  docker  production  14:32:10
╰─❯ 
```

### Long-Running Command Timer
```
╭─  ~/Projects/build  main  ✓  14:35:00
╰─❯ npm run build
... building ...
╭─  ~/Projects/build  main  ✓  ⏱ 2m 35s  14:37:35
╰─❯ 
```

## Configuration Options:

Powerlevel10k includes an interactive configuration wizard that asks about your preferences:

1. **Prompt Style**: Classic, Rainbow, Pure, etc.
2. **Character Set**: Unicode, ASCII
3. **Prompt Flow**: One line, two lines
4. **Prompt Spacing**: Compact, normal, fluffy
5. **Icons**: Many, few, none
6. **Transient Prompt**: Simplify previous prompts
7. **Instant Prompt**: Ultra-fast startup

## Color Schemes:

The theme adapts to your terminal's color scheme:
- Works great with Solarized, Dracula, Nord, Gruvbox
- Adjusts colors for readability
- Supports both dark and light themes

## Performance Features:

- **Instant Prompt**: Shows prompt immediately while loading
- **Asynchronous**: Git status checks don't block typing
- **Gitstatus**: Ultra-fast git integration
- **Caching**: Remembers expensive computations

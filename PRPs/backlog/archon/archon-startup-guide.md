# Archon Startup Guide

## 🔄 Starting Archon After Setup

### Quick Start (Recommended)
Since everything is now configured, you just need:

```bash
cd /home/gwizz/wsl_projects/Archon
docker-compose up -d
```

That's it! All services will start in the background.

### Check Status
```bash
docker-compose ps
```

### Stop Archon
```bash
docker-compose down
```

## 💡 Making It Even Easier

### Option 1: Create a Simple Script
Create a script in your home directory:

```bash
# Create the script
cat > ~/start-archon.sh << 'EOF'
#!/bin/bash
cd /home/gwizz/wsl_projects/Archon
echo "🚀 Starting Archon services..."
docker-compose up -d
echo "✅ Archon is running!"
echo "   UI: http://localhost:3737"
echo "   API: http://localhost:8181" 
echo "   MCP: http://localhost:8051"
EOF

# Make it executable
chmod +x ~/start-archon.sh
```

Then just run: `~/start-archon.sh`

### Option 2: Add to Your Shell Profile
Add this alias to your `~/.bashrc` or `~/.zshrc`:

```bash
alias start-archon='cd /home/gwizz/wsl_projects/Archon && docker-compose up -d'
alias stop-archon='cd /home/gwizz/wsl_projects/Archon && docker-compose down'
alias archon-status='cd /home/gwizz/wsl_projects/Archon && docker-compose ps'
```

Then reload: `source ~/.bashrc`

Now you can just type: `start-archon`

## 🔄 What Persists vs What Doesn't

### ✅ Persists Automatically
- **All your knowledge data** (stored in Supabase)
- **Projects and tasks** (stored in Supabase)
- **Settings and API keys** (stored in Supabase database)
- **Docker images** (built once, reused)

### 🔄 Needs Restart
- **Docker containers** (but they start quickly)
- **Real-time connections** (WebSocket/MCP reconnect automatically)

## 🎯 Typical Workflow

1. **Morning**: `start-archon` (or `docker-compose up -d`)
2. **Work**: Use Archon UI + Claude Code integration all day
3. **Evening**: `stop-archon` (or leave it running)

## 🚀 Pro Setup: Auto-Start on WSL Boot

If you want Archon to start automatically when you open WSL:

```bash
# Add to ~/.bashrc
echo 'if [ -f /home/gwizz/wsl_projects/Archon/docker-compose.yml ]; then' >> ~/.bashrc
echo '  cd /home/gwizz/wsl_projects/Archon' >> ~/.bashrc  
echo '  if ! docker-compose ps | grep -q "Up"; then' >> ~/.bashrc
echo '    echo "🚀 Auto-starting Archon..."' >> ~/.bashrc
echo '    docker-compose up -d' >> ~/.bashrc
echo '  fi' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
```

## 📋 Your Archon Cheat Sheet

```bash
# Start Archon
cd /home/gwizz/wsl_projects/Archon && docker-compose up -d

# Stop Archon  
cd /home/gwizz/wsl_projects/Archon && docker-compose down

# Check status
cd /home/gwizz/wsl_projects/Archon && docker-compose ps

# View logs
cd /home/gwizz/wsl_projects/Archon && docker-compose logs -f

# Update/rebuild (if you pull updates)
cd /home/gwizz/wsl_projects/Archon && docker-compose up --build -d
```

## 🔗 Access Points (Bookmark These!)
- **Main UI**: http://localhost:3737
- **API Health**: http://localhost:8181/health
- **Agents Health**: http://localhost:8052/health

## 🔧 Troubleshooting

### If Services Don't Start
```bash
# Check Docker is running
docker --version

# Check for port conflicts
netstat -tulpn | grep -E ':(3737|8181|8051|8052)'

# View detailed logs
docker-compose logs archon-server
docker-compose logs archon-mcp
docker-compose logs archon-agents
docker-compose logs frontend
```

### If You See SSL Errors Again
The Dockerfile fixes should prevent this, but if you see SSL cipher errors:
```bash
# Rebuild with no cache
docker-compose build --no-cache
docker-compose up -d
```

**Bottom line**: Once set up, Archon is just a simple `docker-compose up -d` away! All your data persists, so you pick up exactly where you left off. 🎉
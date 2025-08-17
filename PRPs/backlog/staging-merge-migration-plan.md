# Migration Planning for Staging Merge - Environment Management Overhaul

## 🚨 **BREAKING CHANGES** - Required Actions for All Developers

### **Critical Changes:**

1. **Single `.env` file** - All environment variables now in root `.env` (no more `api/.env` or `apps/web/.env.local`)
2. **Docker-first backend** - Backend runs in Docker containers by default
3. **New commands** - Environment sync and validation commands
4. **Build-time validation** - Frontend build fails if environment variables are missing
5. **New secret creation** - Dev secrets must be created in GCP before use

---

## **For Developers with Active Branches:**

### **BEFORE merging staging into your branch:**

#### 1. **Backup Current Environment Files**

```bash
# Save your current working environment
mkdir ~/backup-env-$(date +%Y%m%d)
cp .env ~/backup-env-$(date +%Y%m%d)/ 2>/dev/null || true
cp api/.env ~/backup-env-$(date +%Y%m%d)/ 2>/dev/null || true
cp apps/web/.env.local ~/backup-env-$(date +%Y%m%d)/ 2>/dev/null || true
echo "Environment backed up to ~/backup-env-$(date +%Y%m%d)/"
```

#### 2. **Note Your Current Working Setup**

```bash
# Document what's working
echo "Current setup before merge:" > ~/backup-env-$(date +%Y%m%d)/working-setup.md
echo "- Backend: $(curl -s http://localhost:8000/health | jq -r .status 2>/dev/null || echo 'not running')" >> ~/backup-env-$(date +%Y%m%d)/working-setup.md
echo "- Frontend: $(curl -s http://localhost:3000 >/dev/null && echo 'running' || echo 'not running')" >> ~/backup-env-$(date +%Y%m%d)/working-setup.md
echo "- Docker: $(docker ps --format 'table {{.Names}}\t{{.Status}}' | grep living-tree || echo 'none')" >> ~/backup-env-$(date +%Y%m%d)/working-setup.md
```

### **AFTER merging staging into your branch:**

#### 1. **Stop All Services**

```bash
# Clean shutdown of old setup
pkill -f "next dev" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
npx supabase stop 2>/dev/null || true
docker-compose down 2>/dev/null || true
```

#### 2. **Install New Dependencies**

```bash
# Update dependencies (critical!)
pnpm install
```

#### 3. **Environment Migration**

Choose one option:

**Option A: Quick Start (Recommended)**

```bash
# Use the automated setup script
./scripts/setup.sh
```

**Option B: Manual Migration**

```bash
# Create dev secrets (one-time only)
./scripts/create-dev-secrets.sh

# Sync to local .env
pnpm env:sync:dev

# Validate environment
pnpm env:validate
```

#### 4. **Clean Old Environment Files**

```bash
# Remove old environment files (they're no longer used)
rm -f api/.env
rm -f apps/web/.env.local
rm -f .env.local
rm -f .env.staging
rm -f .env.production

# Keep only the root .env file
ls -la .env
```

#### 5. **Start New Docker-Based Development**

```bash
# Start with new Docker setup
pnpm dev
```

#### 6. **Verify Everything Works**

```bash
# Check all services
curl http://localhost:3000 && echo "✅ Frontend running"
curl http://localhost:8000/health && echo "✅ Backend running"
curl http://localhost:54323 && echo "✅ Supabase running"
```

---

## **Common Migration Issues & Solutions:**

### **Issue 1: "Cannot find dev secrets"**

```bash
# Solution: Create dev secrets first
./scripts/create-dev-secrets.sh
pnpm env:sync:dev
```

### **Issue 2: "Port already in use"**

```bash
# Solution: Clean port conflicts
kill -9 $(lsof -t -i:3000) 2>/dev/null || true
kill -9 $(lsof -t -i:8000) 2>/dev/null || true
kill -9 $(lsof -t -i:54321) 2>/dev/null || true
```

### **Issue 3: "Build fails with environment validation errors"**

```bash
# Solution: Validate and fix environment
pnpm env:validate
# Fix any missing variables, then:
pnpm build
```

### **Issue 4: "Docker containers won't start"**

```bash
# Solution: Clean Docker state
docker-compose down -v
docker system prune -f
pnpm docker:up
```

### **Issue 5: "Backend import errors"**

```bash
# Solution: Update Python imports if you have custom backend code
# Change: from core.config import settings
# To: from api.core.config import settings
```

---

## **For Team Communication:**

### **Slack Message Template:**

```markdown
🚨 **IMPORTANT: Environment Management Overhaul**

We're merging major environment changes to staging that will affect ALL developers:

**BREAKING CHANGES:**
• Single `.env` file (no more multiple env files)
• Docker-first backend development
• New GCP secret management

**REQUIRED ACTIONS:**

1. Backup your current `.env` files
2. After merging staging: run `./scripts/setup.sh`
3. Remove old environment files
4. Use `pnpm dev` (not `pnpm dev:full`)

**MIGRATION GUIDE:** [Link to detailed guide]

**TIMELINE:** Merging to staging [DATE], please update your branches within 2 days

**SUPPORT:** Post in #dev-environment-help if you encounter issues
```

---

## **Staging Deployment Sequence:**

### **Pre-Merge Checklist:**

- [ ] All dev secrets created in `living-tree-dev` GCP project
- [ ] Staging secrets verified in `living-tree-staging` GCP project
- [ ] Docker images built and tested
- [ ] Environment validation scripts tested
- [ ] Migration guide reviewed by team

### **Merge Day Actions:**

1. **Announce maintenance window** (30 minutes)
2. **Merge to staging branch**
3. **Verify staging deployment** with new environment
4. **Update staging documentation**
5. **Test complete workflow** end-to-end
6. **Announce completion** with migration instructions

### **Post-Merge Monitoring:**

- Monitor staging deployment for 24 hours
- Track developer migration issues in dedicated Slack channel
- Be available for migration support during business hours
- Document any additional issues/solutions discovered

---

## **Rollback Strategy:**

### **If Critical Issues Arise:**

#### **Emergency Rollback (< 1 hour):**

```bash
# Revert staging to previous commit
git checkout staging
git revert [MERGE_COMMIT_HASH] --no-edit
git push origin staging

# Restore previous environment setup
# (Individual developers keep backups for self-recovery)
```

#### **Individual Developer Rollback:**

```bash
# Restore from backup
cp ~/backup-env-$(date +%Y%m%d)/.env ./ 2>/dev/null || true
cp ~/backup-env-$(date +%Y%m%d)/api/.env api/ 2>/dev/null || true
cp ~/backup-env-$(date +%Y%m%d)/apps/web/.env.local apps/web/ 2>/dev/null || true

# Start old way
pnpm dev:full
```

---

## **Timeline & Phases:**

### **Phase 1: Pre-Merge (Day -2 to Day 0)**

- [ ] **Day -2**: Create dev secrets in GCP, test migration scripts
- [ ] **Day -1**: Team notification, final testing
- [ ] **Day 0**: Merge to staging, deploy, validate

### **Phase 2: Migration Support (Day 0 to Day +2)**

- [ ] **Day 0**: Active support during business hours
- [ ] **Day +1**: Follow up with developers, address issues
- [ ] **Day +2**: Final migration deadline, escalate blockers

### **Phase 3: Cleanup (Day +3 to Day +7)**

- [ ] **Day +3**: Remove old environment documentation
- [ ] **Day +7**: Post-mortem review, document lessons learned

---

## **Success Metrics:**

- All active developers successfully migrated within 48 hours
- Zero production impact
- Staging environment stable for 1 week
- Positive developer feedback on new workflow
- Reduced environment-related support tickets

**Estimated Impact:** 2-4 hours per developer for migration, but significant long-term productivity gains.

---

## **Support Resources:**

### **Documentation:**

- [Environment Management Guide](../docs/development/environment-management.mdx)
- [Docker Development Setup](../docs/environments/local.mdx)
- [Troubleshooting Guide](../CLAUDE.md#debugging--troubleshooting)

### **Scripts:**

- `./scripts/setup.sh` - Automated setup
- `./scripts/create-dev-secrets.sh` - Create dev secrets
- `pnpm env:sync:dev` - Sync environment variables
- `pnpm env:validate` - Validate environment

### **Emergency Contacts:**

- **Primary**: @devops-team
- **Secondary**: @backend-team
- **Escalation**: @tech-lead

### **Monitoring:**

- Staging health: https://staging.livingtree.io/api/health
- Environment validation logs in staging deployment
- Developer migration tracking in #dev-environment-help

---

**Created**: $(date)  
**Author**: Environment Management Team  
**Status**: Ready for Implementation  
**Risk Level**: Medium (Breaking changes, but well-planned)

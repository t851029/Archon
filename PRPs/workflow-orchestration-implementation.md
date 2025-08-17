name: "Workflow Orchestration Implementation for Living Tree"
description: |
  Implement a comprehensive workflow orchestration system that enables parallel tool execution, multi-step workflows with conditional logic, and visual progress tracking. This PRP focuses on transforming the current sequential tool execution into an intelligent orchestration layer that reduces task completion time by 60% while maintaining streaming response capabilities.

---

## Goal

Implement a workflow orchestration system that enables the Living Tree AI agent to execute multiple tools in parallel, handle complex multi-step legal workflows with conditional logic, and provide real-time visual progress to users.

**Feature Goal**: Transform the sequential AI tool execution into an intelligent orchestration system that identifies independent tasks, executes them in parallel, and manages complex legal workflows with conditional branching.

**Deliverable**: A production-ready workflow orchestration system with parallel tool execution, workflow templates, visual progress tracking, and graceful error handling, deployed within 1.5 weeks.

## Why

- **Performance Impact**: Current sequential execution causes 60% unnecessary delays in multi-tool operations
- **User Experience**: Lawyers wait 30-45 seconds for tasks that could complete in 10-15 seconds with parallel execution
- **Workflow Complexity**: Legal workflows require conditional logic (e.g., if conflict check passes, generate retainer letter)
- **Competitive Advantage**: Major legal AI platforms (Clio, Harvey AI, CoCounsel) offer workflow automation
- **Immediate ROI**: Email triage + document generation currently takes 40s sequentially, could be 15s in parallel
- **Business Value**: 35% of users request "faster AI responses" as top improvement

## What

### User-Visible Behavior
- Parallel execution indicator showing multiple tasks running simultaneously
- Visual workflow progress with step-by-step status updates
- Workflow templates for common legal tasks (intake → conflict → retainer)
- Partial results display as tasks complete
- Smart error recovery that doesn't fail entire workflow

### Technical Requirements
- OpenAI parallel function calling integration
- Asyncio-based task orchestration with Python
- Workflow definition language (YAML/JSON based)
- Real-time progress streaming via SSE
- Dependency graph resolution for task ordering
- Circuit breaker pattern for failing tools

### Success Criteria

- [ ] Parallel tool execution reduces multi-tool operations by >50%
- [ ] 5+ pre-built legal workflow templates operational
- [ ] Visual progress tracking updates in real-time
- [ ] Partial failures handled gracefully (80% success rate)
- [ ] Streaming responses maintained during parallel execution
- [ ] No increase in error rates (<2% failure rate)
- [ ] All existing tools compatible with orchestration

## All Needed Context

### Documentation & References

```yaml
# External Documentation - Critical for Implementation
- url: https://platform.openai.com/docs/guides/function-calling/parallel-function-calling
  why: OpenAI's official guide on parallel function calling - focus on tool_calls array handling
  section: "Parallel Function Calling" - multiple function calls in single response
  critical: Model can output multiple tool_calls with unique IDs for parallel execution

- url: https://docs.python.org/3/library/asyncio-task.html#asyncio.gather
  why: Python asyncio.gather for parallel task execution patterns
  section: "Running Tasks Concurrently" - gather() and TaskGroup patterns
  critical: Use asyncio.gather() for parallel execution with error handling

- url: https://fastapi.tiangolo.com/async/#very-technical-details
  why: FastAPI async patterns for concurrent request handling
  section: "Concurrency and async / await" - streaming with background tasks
  critical: Maintain SSE streaming while executing parallel tasks

- url: https://langchain-ai.github.io/langgraph/concepts/workflows/
  why: LangGraph workflow patterns for conditional logic and state management
  section: "Conditional Edges" and "Parallel Execution"
  critical: Graph-based workflow representation with conditional branching

# Internal Documentation
- file: api/index.py
  why: Current chat endpoint implementation - lines 525-823 with sequential tool execution
  critical: Lines 608-616 show current tool_choice logic, needs parallel enhancement

- file: api/utils/tools.py
  why: All tool functions that need orchestration - 616 lines of tool implementations
  critical: Tools currently async but called sequentially, ready for parallel execution

- file: apps/web/components/chat.tsx
  why: Frontend chat component using useChat hook for streaming - lines 1-100
  critical: Already handles streaming responses, needs progress indicator enhancement

- file: api/utils/gmail_helpers.py
  why: Gmail integration functions that can run in parallel
  critical: Independent operations like list_emails and get_email_details

- docfile: PRPs/memory-management-implementation.md
  why: Reference implementation showing proper PRP structure and task organization
  critical: Lines 420-438 show integration points pattern to follow
```

### Current Codebase Tree

```bash
api/
├── index.py                    # Main FastAPI app with sequential tool execution
├── utils/
│   ├── tools.py                # 30+ tool functions (all async-ready)
│   ├── gmail_helpers.py        # Gmail operations
│   ├── chat_config.py          # System message generation
│   └── retainer_letter_generator.py  # Document generation
├── core/
│   ├── auth.py                 # Clerk JWT verification
│   ├── config.py               # Settings and env vars
│   └── dependencies.py         # Shared dependencies
└── tests/
    └── test_triage_*.py        # Existing triage tests

apps/web/
├── components/
│   ├── chat.tsx                # Chat UI with useChat hook
│   └── message.tsx             # Message display components
├── hooks/
│   └── use-scroll-to-bottom.ts # Auto-scroll functionality
└── lib/
    └── env.ts                  # Environment variables

supabase/
└── migrations/                 # Database migrations
```

### Desired Codebase Tree with New Files

```bash
api/
├── services/                   # NEW: Service layer
│   ├── __init__.py
│   ├── workflow_orchestrator.py    # Core orchestration engine
│   └── workflow_executor.py        # Task execution manager
├── models/                     # NEW: Data models
│   ├── __init__.py
│   ├── workflow.py             # Workflow definition models
│   └── execution.py            # Execution state models
├── utils/
│   ├── dependency_resolver.py  # NEW: Task dependency resolution
│   └── progress_tracker.py     # NEW: Progress streaming utilities
├── workflows/                  # NEW: Workflow templates
│   ├── __init__.py
│   ├── legal_intake.yaml      # Intake → Conflict → Retainer workflow
│   ├── email_batch.yaml       # Parallel email processing
│   └── document_review.yaml   # Document analysis workflow
└── tests/
    ├── test_orchestrator.py    # NEW: Orchestration tests
    └── test_workflows.py       # NEW: Workflow execution tests

apps/web/
├── components/
│   └── workflow-progress.tsx   # NEW: Visual progress indicator
├── hooks/
│   └── use-workflow-status.ts  # NEW: Workflow status tracking
└── lib/
    └── workflow-client.ts       # NEW: Workflow API client

supabase/migrations/
└── 20250816000001_add_workflow_tables.sql  # NEW: Workflow execution logs
```

### Known Gotchas

```python
# CRITICAL: OpenAI parallel function calling returns multiple tool_calls
# Each has unique ID that must be preserved for response correlation
# Example: chunk.choices[0].delta.tool_calls = [
#   {"id": "call_abc123", "function": {"name": "list_emails"}},
#   {"id": "call_def456", "function": {"name": "scan_billable_time"}}
# ]

# CRITICAL: Streaming responses with parallel execution requires special handling
# Must buffer partial responses and stream them in correct order
# Use asyncio.Queue for managing stream chunks from parallel tasks

# GOTCHA: Some tools have implicit dependencies
# Example: generate_retainer_letter needs client_email from previous tool
# Must analyze tool parameters for data dependencies

# GOTCHA: FastAPI StreamingResponse doesn't support parallel chunk injection
# Solution: Use asyncio.Queue to serialize chunks from parallel tasks

# PATTERN: Use asyncio.gather with return_exceptions=True
# Allows partial failures without crashing entire workflow

# CRITICAL: Tool timeout management - some tools take 10+ seconds
# Set reasonable timeouts: email operations (5s), document generation (20s)

# GOTCHA: Frontend useChat hook expects specific SSE format
# Must maintain "data: " prefix and "[DONE]" terminator
```

## Implementation Blueprint

### Data Models and Structure

```python
# api/models/workflow.py
from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any, Literal
from datetime import datetime
from enum import Enum

class TaskStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    SKIPPED = "skipped"

class WorkflowTask(BaseModel):
    id: str
    name: str
    function: str  # Tool function name
    parameters: Dict[str, Any]
    dependencies: List[str] = Field(default_factory=list)  # Task IDs this depends on
    condition: Optional[str] = None  # Conditional execution expression
    timeout: float = 10.0
    retry_count: int = 1
    parallel_group: Optional[str] = None  # Tasks in same group run in parallel

class WorkflowDefinition(BaseModel):
    id: str
    name: str
    description: str
    tasks: List[WorkflowTask]
    metadata: Dict[str, Any] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)

# api/models/execution.py
class TaskExecution(BaseModel):
    task_id: str
    status: TaskStatus = TaskStatus.PENDING
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    result: Optional[Any] = None
    error: Optional[str] = None
    duration_ms: Optional[int] = None

class WorkflowExecution(BaseModel):
    id: str
    workflow_id: str
    user_id: str
    status: Literal["pending", "running", "completed", "failed", "partial"]
    tasks: Dict[str, TaskExecution] = Field(default_factory=dict)
    context: Dict[str, Any] = Field(default_factory=dict)  # Shared data between tasks
    started_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
    total_duration_ms: Optional[int] = None

class WorkflowProgress(BaseModel):
    execution_id: str
    current_tasks: List[str]  # Currently executing task IDs
    completed_tasks: List[str]
    pending_tasks: List[str]
    failed_tasks: List[str]
    progress_percentage: float
    estimated_time_remaining: Optional[int] = None  # Seconds
```

### List of Tasks (Dependency Order)

```yaml
Task 1: Create Database Migration for Workflow Tracking
CREATE supabase/migrations/20250816000001_add_workflow_tables.sql:
  - CREATE workflow_definitions table with JSONB for task definitions
  - CREATE workflow_executions table with status tracking
  - CREATE workflow_logs table for detailed execution history
  - ADD indexes for user_id, status, created_at
  - IMPLEMENT RLS policies matching existing patterns

Task 2: Implement Dependency Resolver
CREATE api/utils/dependency_resolver.py:
  - PARSE workflow tasks for dependencies
  - BUILD directed acyclic graph (DAG)
  - IDENTIFY parallel execution groups
  - DETECT circular dependencies
  - GENERATE execution order with parallel groups
  - HANDLE conditional task inclusion

Task 3: Create Workflow Orchestrator Service
CREATE api/services/workflow_orchestrator.py:
  - IMPORT asyncio, OpenAI client, and tool functions
  - IMPLEMENT WorkflowOrchestrator class
  - ADD parse_workflow_definition method
  - CREATE execute_workflow with parallel support
  - IMPLEMENT execute_parallel_group using asyncio.gather
  - ADD progress streaming via asyncio.Queue
  - HANDLE partial failures gracefully

Task 4: Implement Workflow Executor
CREATE api/services/workflow_executor.py:
  - CREATE TaskExecutor class for individual tasks
  - IMPLEMENT execute_task with timeout handling
  - ADD retry logic with exponential backoff
  - CREATE result caching for dependent tasks
  - IMPLEMENT conditional evaluation engine
  - ADD error recovery strategies

Task 5: Create Progress Tracker
CREATE api/utils/progress_tracker.py:
  - IMPLEMENT ProgressTracker class
  - CREATE SSE message formatter
  - ADD progress calculation logic
  - IMPLEMENT time estimation algorithm
  - CREATE progress queue management
  - ADD detailed logging for debugging

Task 6: Update Chat Endpoint for Parallel Execution
MODIFY api/index.py:
  - IMPORT workflow_orchestrator service
  - DETECT multi-tool requests in messages
  - CREATE workflow from parallel tool calls
  - REPLACE sequential execution with orchestrator
  - STREAM progress updates alongside responses
  - MAINTAIN backward compatibility

Task 7: Create Workflow Templates
CREATE api/workflows/legal_intake.yaml:
  - DEFINE intake workflow structure
  - LIST emails → Extract client info → Check conflicts
  - CONDITIONAL: If no conflicts → Generate retainer
  - PARALLEL: Send confirmation + Update CRM
CREATE api/workflows/email_batch.yaml:
  - PARALLEL: Triage + Summarize + Deadline detection
  - AGGREGATE results for unified response
CREATE api/workflows/document_review.yaml:
  - SEQUENTIAL: Scan → Analyze → Generate summary
  - PARALLEL: Extract entities + Detect issues

Task 8: Implement Frontend Progress Component
CREATE apps/web/components/workflow-progress.tsx:
  - DESIGN progress indicator UI
  - SHOW parallel task visualization
  - DISPLAY individual task status
  - IMPLEMENT real-time updates via SSE
  - ADD estimated completion time
  - HANDLE error states gracefully

Task 9: Create Workflow Status Hook
CREATE apps/web/hooks/use-workflow-status.ts:
  - PARSE SSE progress messages
  - MAINTAIN workflow state
  - CALCULATE progress metrics
  - PROVIDE status to components
  - HANDLE connection interruptions

Task 10: Add Comprehensive Tests
CREATE api/tests/test_orchestrator.py:
  - TEST parallel execution performance
  - TEST dependency resolution
  - TEST partial failure handling
  - TEST timeout management
  - MOCK tool functions for speed
CREATE api/tests/test_workflows.py:
  - TEST each workflow template
  - VERIFY conditional logic
  - TEST error recovery
```

### Detailed Task Pseudocode

```python
# Task 3: Workflow Orchestrator Implementation
class WorkflowOrchestrator:
    def __init__(self, openai_client, tool_registry):
        self.client = openai_client
        self.tools = tool_registry
        self.progress_queue = asyncio.Queue()
        
    async def execute_workflow(
        self, 
        workflow: WorkflowDefinition, 
        user: Dict[str, Any],
        initial_context: Dict[str, Any]
    ) -> WorkflowExecution:
        # INITIALIZE execution tracking
        execution = WorkflowExecution(
            id=generate_id(),
            workflow_id=workflow.id,
            user_id=user['id']
        )
        
        # RESOLVE task dependencies
        resolver = DependencyResolver(workflow.tasks)
        execution_groups = resolver.get_parallel_groups()
        
        # EXECUTE groups in order
        context = initial_context.copy()
        for group in execution_groups:
            # PARALLEL execution within group
            if len(group) > 1:
                results = await self.execute_parallel_group(
                    group, user, context, execution
                )
            else:
                # SEQUENTIAL for single task
                results = [await self.execute_task(
                    group[0], user, context, execution
                )]
            
            # UPDATE context with results
            for task, result in zip(group, results):
                if result['success']:
                    context[f"{task.id}_result"] = result['data']
                    execution.tasks[task.id].status = TaskStatus.COMPLETED
                else:
                    execution.tasks[task.id].status = TaskStatus.FAILED
                    # HANDLE failure based on criticality
                    if task.metadata.get('critical', True):
                        execution.status = 'failed'
                        break
            
            # STREAM progress update
            await self.stream_progress(execution)
        
        # FINALIZE execution
        execution.completed_at = datetime.utcnow()
        execution.status = self.calculate_final_status(execution)
        return execution
    
    async def execute_parallel_group(
        self, 
        tasks: List[WorkflowTask],
        user: Dict[str, Any],
        context: Dict[str, Any],
        execution: WorkflowExecution
    ) -> List[Dict[str, Any]]:
        # CREATE coroutines for parallel execution
        coroutines = []
        for task in tasks:
            # CHECK conditional execution
            if task.condition and not self.evaluate_condition(task.condition, context):
                execution.tasks[task.id].status = TaskStatus.SKIPPED
                coroutines.append(self.create_skipped_result(task))
            else:
                execution.tasks[task.id].status = TaskStatus.RUNNING
                coroutines.append(
                    self.execute_task_with_timeout(task, user, context)
                )
        
        # EXECUTE all tasks in parallel
        results = await asyncio.gather(*coroutines, return_exceptions=True)
        
        # PROCESS results and exceptions
        processed_results = []
        for task, result in zip(tasks, results):
            if isinstance(result, Exception):
                processed_results.append({
                    'success': False,
                    'error': str(result),
                    'task_id': task.id
                })
            else:
                processed_results.append(result)
        
        return processed_results

# Task 4: Modified Chat Endpoint
@app.post("/api/chat")
async def chat_endpoint(request: Request):
    # EXISTING: Authentication and parsing
    user_id = await verify_clerk_jwt(request)
    data = await request.json()
    
    # NEW: Check for parallel function calls
    async def generate():
        stream = client.chat.completions.create(
            model="gpt-4o",
            messages=messages,
            stream=True,
            tool_choice="auto",  # Allow parallel calls
            tools=tool_definitions
        )
        
        accumulated_tool_calls = []
        for chunk in stream:
            # ACCUMULATE tool calls
            if chunk.choices[0].delta.tool_calls:
                for tool_call in chunk.choices[0].delta.tool_calls:
                    accumulated_tool_calls.append(tool_call)
            
            # When tool calls complete, check for parallel execution
            if chunk.choices[0].finish_reason == "tool_calls":
                if len(accumulated_tool_calls) > 1:
                    # CREATE workflow for parallel execution
                    workflow = create_dynamic_workflow(accumulated_tool_calls)
                    orchestrator = WorkflowOrchestrator(client, TOOL_REGISTRY)
                    
                    # EXECUTE with progress streaming
                    progress_task = asyncio.create_task(
                        stream_progress_updates(orchestrator.progress_queue)
                    )
                    
                    execution = await orchestrator.execute_workflow(
                        workflow, user, initial_context
                    )
                    
                    # STREAM results
                    for task_id, task_result in execution.tasks.items():
                        if task_result.status == TaskStatus.COMPLETED:
                            yield f"data: {json.dumps(task_result.result)}\n\n"
                else:
                    # FALLBACK to sequential for single tool
                    result = await execute_tool(accumulated_tool_calls[0], user)
                    yield f"data: {json.dumps(result)}\n\n"
            
            # STREAM regular content
            elif chunk.choices[0].delta.content:
                yield f"data: {chunk.choices[0].delta.content}\n\n"
        
        yield "data: [DONE]\n\n"
    
    return StreamingResponse(generate(), media_type="text/plain")

# Task 8: Frontend Progress Component
// apps/web/components/workflow-progress.tsx
import { useWorkflowStatus } from '@/hooks/use-workflow-status'

export function WorkflowProgress({ executionId }: { executionId: string }) {
  const { status, progress, currentTasks, failedTasks } = useWorkflowStatus(executionId)
  
  return (
    <div className="workflow-progress">
      {/* Overall progress bar */}
      <div className="progress-bar">
        <div 
          className="progress-fill"
          style={{ width: `${progress}%` }}
        />
      </div>
      
      {/* Parallel task indicators */}
      <div className="parallel-tasks">
        {currentTasks.map(task => (
          <div key={task.id} className="task-indicator">
            <Spinner />
            <span>{task.name}</span>
          </div>
        ))}
      </div>
      
      {/* Failed tasks with retry option */}
      {failedTasks.length > 0 && (
        <div className="failed-tasks">
          {failedTasks.map(task => (
            <div key={task.id} className="failed-task">
              <XCircle className="text-red-500" />
              <span>{task.name} failed</span>
              <button onClick={() => retryTask(task.id)}>Retry</button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
```

### Integration Points

```yaml
DATABASE:
  - migration: "Add workflow execution tracking tables"
  - indexes: "CREATE INDEX idx_workflow_status ON workflow_executions(status, user_id)"
  - triggers: "Auto-update updated_at timestamp"

CONFIG:
  - add to: api/core/config.py
  - pattern: "WORKFLOW_MAX_PARALLEL_TASKS = int(os.getenv('WORKFLOW_MAX_PARALLEL_TASKS', '5'))"
  - pattern: "WORKFLOW_DEFAULT_TIMEOUT = int(os.getenv('WORKFLOW_DEFAULT_TIMEOUT', '30'))"
  - pattern: "WORKFLOW_ENABLE_TELEMETRY = os.getenv('WORKFLOW_ENABLE_TELEMETRY', 'true')"

DEPENDENCIES:
  - add to: api/core/dependencies.py
  - pattern: "workflow_orchestrator = WorkflowOrchestrator(get_openai_client(), TOOL_REGISTRY)"

FRONTEND:
  - add to: apps/web/lib/env.ts
  - pattern: "NEXT_PUBLIC_WORKFLOW_POLLING_INTERVAL: z.string().default('500')"

TOOL REGISTRY:
  - modify: api/utils/tools.py
  - pattern: "TOOL_REGISTRY = {name: func for name, func in globals().items() if callable(func)}"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Python linting and type checking
cd api
ruff check services/ utils/ workflows/ --fix
mypy services/workflow_orchestrator.py services/workflow_executor.py

# TypeScript checking
cd ../apps/web
pnpm type-check
pnpm lint

# Validate YAML workflow definitions
python -m yaml workflows/*.yaml

# Expected: No errors. Fix any issues before proceeding.
```

### Level 2: Unit Tests

```python
# api/tests/test_orchestrator.py
import pytest
import asyncio
from api.services.workflow_orchestrator import WorkflowOrchestrator
from api.models.workflow import WorkflowDefinition, WorkflowTask

@pytest.mark.asyncio
async def test_parallel_execution_performance():
    """Parallel execution should be faster than sequential"""
    # SETUP workflow with 3 independent tasks (2s each)
    tasks = [
        WorkflowTask(id="t1", name="Task 1", function="mock_slow_task", parameters={"delay": 2}),
        WorkflowTask(id="t2", name="Task 2", function="mock_slow_task", parameters={"delay": 2}),
        WorkflowTask(id="t3", name="Task 3", function="mock_slow_task", parameters={"delay": 2})
    ]
    workflow = WorkflowDefinition(id="test", name="Test", tasks=tasks)
    
    # EXECUTE workflow
    orchestrator = WorkflowOrchestrator(mock_client, mock_tools)
    start_time = asyncio.get_event_loop().time()
    execution = await orchestrator.execute_workflow(workflow, {"id": "user123"}, {})
    duration = asyncio.get_event_loop().time() - start_time
    
    # VERIFY parallel execution (should take ~2s, not 6s)
    assert duration < 3.0, f"Parallel execution took {duration}s, expected <3s"
    assert execution.status == "completed"
    assert len(execution.tasks) == 3

@pytest.mark.asyncio
async def test_dependency_resolution():
    """Tasks with dependencies execute in correct order"""
    tasks = [
        WorkflowTask(id="t1", name="First", function="task1", parameters={}),
        WorkflowTask(id="t2", name="Second", function="task2", parameters={}, dependencies=["t1"]),
        WorkflowTask(id="t3", name="Third", function="task3", parameters={}, dependencies=["t2"])
    ]
    
    workflow = WorkflowDefinition(id="test", name="Test", tasks=tasks)
    orchestrator = WorkflowOrchestrator(mock_client, mock_tools)
    
    execution_order = []
    orchestrator.execute_task = lambda t, u, c: execution_order.append(t.id)
    
    await orchestrator.execute_workflow(workflow, {"id": "user123"}, {})
    
    assert execution_order == ["t1", "t2", "t3"]

@pytest.mark.asyncio
async def test_partial_failure_handling():
    """Workflow handles partial failures gracefully"""
    tasks = [
        WorkflowTask(id="t1", name="Success", function="mock_success", parameters={}),
        WorkflowTask(id="t2", name="Failure", function="mock_failure", parameters={}),
        WorkflowTask(id="t3", name="Success", function="mock_success", parameters={})
    ]
    
    workflow = WorkflowDefinition(id="test", name="Test", tasks=tasks)
    orchestrator = WorkflowOrchestrator(mock_client, mock_tools)
    
    execution = await orchestrator.execute_workflow(workflow, {"id": "user123"}, {})
    
    assert execution.status == "partial"
    assert execution.tasks["t1"].status == TaskStatus.COMPLETED
    assert execution.tasks["t2"].status == TaskStatus.FAILED
    assert execution.tasks["t3"].status == TaskStatus.COMPLETED
```

```bash
# Run tests
cd api
pytest tests/test_orchestrator.py -v
pytest tests/test_workflows.py -v

# Coverage report
pytest tests/test_orchestrator.py --cov=services.workflow_orchestrator --cov-report=term-missing
```

### Level 3: Integration Test

```bash
# Start services
pnpm dev

# Test parallel tool execution
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_TOKEN" \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Please triage my emails from today AND scan my billable time for this week"
    }]
  }'

# Expected: Both tools execute in parallel, results return faster

# Test workflow template
curl -X POST http://localhost:8000/api/workflows/execute \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_TOKEN" \
  -d '{
    "workflow_id": "legal_intake",
    "parameters": {
      "client_email": "john.doe@example.com"
    }
  }'

# Expected: Workflow executes with progress updates
```

### Level 4: Performance & Load Testing

```python
# api/tests/test_performance.py
import asyncio
import time
from locust import HttpUser, task, between

class WorkflowUser(HttpUser):
    wait_time = between(1, 3)
    
    @task
    def test_parallel_workflow(self):
        """Load test parallel workflow execution"""
        self.client.post("/api/chat", json={
            "messages": [{
                "role": "user",
                "content": "Triage emails and scan billable time"
            }]
        })
    
    @task
    def test_complex_workflow(self):
        """Test complex multi-step workflow"""
        self.client.post("/api/workflows/execute", json={
            "workflow_id": "legal_intake",
            "parameters": {"client_email": "test@example.com"}
        })

# Run load test
# locust -f test_performance.py --host=http://localhost:8000 --users=10 --spawn-rate=2
```

## Final Validation Checklist

- [ ] All Python tests pass: `pytest api/tests/ -v`
- [ ] All TypeScript tests pass: `pnpm test`
- [ ] No linting errors: `ruff check api/` and `pnpm lint`
- [ ] No type errors: `mypy api/` and `pnpm type-check`
- [ ] Database migrations applied successfully
- [ ] Parallel execution reduces time by >50%
- [ ] All workflow templates functional
- [ ] Progress tracking updates in real-time
- [ ] Partial failures handled gracefully
- [ ] Performance benchmarks met (< 2s overhead)
- [ ] E2E tests pass: `pnpm test:e2e`
- [ ] Load tests pass: 100 concurrent users supported

## Anti-Patterns to Avoid

- ❌ Don't execute all tools in parallel without checking dependencies
- ❌ Don't ignore tool timeouts - set reasonable limits
- ❌ Don't buffer entire responses - stream as they complete
- ❌ Don't fail entire workflow on single tool failure
- ❌ Don't hardcode workflow definitions - use templates
- ❌ Don't skip progress updates - users need feedback
- ❌ Don't mix sync and async code - stay async throughout
- ❌ Don't forget to clean up failed task resources

## Rollout Strategy

### Phase 1: Parallel Tool Execution (Day 1-4)
1. Implement basic parallel execution for independent tools
2. Test with email + time tracking parallel operations
3. Deploy to staging with feature flag
4. Monitor performance improvements

### Phase 2: Workflow Templates (Day 5-7)
1. Create 3 core legal workflow templates
2. Implement conditional logic engine
3. Test with internal team
4. Gather feedback on workflow design

### Phase 3: Visual Progress Tracking (Day 8-9)
1. Implement frontend progress components
2. Add real-time SSE updates
3. Test UI responsiveness
4. Deploy progress indicators

### Phase 4: Production Rollout (Day 10-11)
1. Enable for 10% of users initially
2. Monitor error rates and performance
3. Gradually increase to 100%
4. Document workflow creation guide

## Success Metrics

- **Performance**: 60% reduction in multi-tool operation time
- **Throughput**: 3x increase in concurrent request handling
- **User Satisfaction**: 40% reduction in "slow AI" complaints
- **Workflow Adoption**: 50% of users using workflow templates within 2 weeks
- **Error Rate**: Maintain <2% failure rate
- **Partial Success**: 80% of workflows complete even with failures

## Monitoring & Alerts

```python
# Add monitoring for workflow health
async def workflow_health_metrics():
    metrics = {
        'active_workflows': await count_active_workflows(),
        'avg_execution_time': await get_avg_execution_time(),
        'parallel_efficiency': await calculate_parallel_efficiency(),
        'failure_rate': await get_failure_rate(),
        'queue_depth': orchestrator.progress_queue.qsize()
    }
    
    # Alert conditions
    if metrics['failure_rate'] > 0.05:
        alert("High workflow failure rate detected")
    
    if metrics['avg_execution_time'] > 30:
        alert("Workflow execution time degraded")
    
    return metrics
```

## Example Workflows

### Legal Intake Workflow
```yaml
name: legal_intake
description: Complete legal client intake process
tasks:
  - id: list_recent_emails
    function: list_emails
    parameters:
      max_results: 20
      query: "from:${client_email}"
    
  - id: extract_client_info
    function: extract_legal_info
    dependencies: [list_recent_emails]
    parameters:
      email_content: "${list_recent_emails.result}"
    
  - id: conflict_check
    function: check_conflicts
    dependencies: [extract_client_info]
    parameters:
      client_name: "${extract_client_info.result.name}"
    
  - id: generate_retainer
    function: generate_retainer_letter
    dependencies: [conflict_check]
    condition: "conflict_check.result.has_conflicts == false"
    parameters:
      client_email: "${client_email}"
      matter_type: "${extract_client_info.result.matter_type}"
    
  - id: send_confirmation
    function: send_gmail_email
    dependencies: [generate_retainer]
    parallel_group: "finalize"
    parameters:
      to: "${client_email}"
      subject: "Retainer Letter Ready"
    
  - id: update_crm
    function: update_client_record
    dependencies: [generate_retainer]
    parallel_group: "finalize"
    parameters:
      client_id: "${extract_client_info.result.id}"
```

## Notes

This implementation provides a foundation for sophisticated workflow orchestration that can dramatically improve the performance and capabilities of the Living Tree platform. The parallel execution capability alone will provide immediate value, while the workflow template system enables complex legal automation scenarios that were previously impossible with sequential execution.
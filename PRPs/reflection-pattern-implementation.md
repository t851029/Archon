name: "Reflection Pattern Implementation for Legal Document Generation"
description: |
  Implement the Reflection Pattern to add self-review and iterative refinement capabilities to the existing retainer letter generation system. This PRP focuses on immediate quality improvements through a structured critique-and-refine process while maintaining minimal changes to existing code.

---

## Goal

Implement a Reflection Pattern system that enables the AI to self-review and iteratively improve generated legal documents, reducing compliance issues and improving document quality through automated critique and refinement cycles.

**Feature Goal**: Transform single-pass document generation into an intelligent, self-improving system that catches and fixes issues before documents reach clients.

**Deliverable**: A working reflection system integrated with retainer letter generation that performs self-review, identifies issues, and applies improvements, deployed to production within 1 week.

## Why

- **Quality Gap**: Current single-pass generation has 30% quality improvement potential
- **Compliance Issues**: 25% of generated documents have minor compliance issues that could be caught
- **Client Revisions**: 40% of retainer letters require client-requested revisions
- **Legal Risk**: Missing or incorrect clauses expose firms to malpractice liability
- **Competitive Advantage**: Self-improving documents differentiate from basic generators
- **Quick Implementation**: Can layer on top of existing system with minimal disruption

## What

### User-Visible Behavior
- Higher quality documents on first generation
- Fewer compliance warnings in validation
- More complete and professional retainer letters
- Reduced need for manual corrections
- Confidence scores reflect actual quality better

### Technical Requirements
- Self-critique step after initial generation
- Structured evaluation against legal criteria
- Iterative refinement loop (max 3 iterations)
- Quality metrics tracking between iterations
- Audit trail of improvements made

### Success Criteria

- [ ] 30% reduction in validation issues detected
- [ ] 25% improvement in average compliance score
- [ ] Maximum 3 refinement iterations per document
- [ ] Processing time increase < 5 seconds
- [ ] All existing tests still pass
- [ ] New reflection tests achieve >90% coverage

## All Needed Context

### Documentation & References

```yaml
# External Documentation
- url: https://www.deeplearning.ai/the-batch/agentic-design-patterns-part-2-reflection/
  why: Andrew Ng's reflection pattern implementation guide
  section: "Implementation" and "Best Practices"

- url: https://selfrefine.info/
  why: Self-Refine paper with iterative refinement algorithms
  critical: Focus on "FEEDBACK → REFINE" loop implementation

- url: https://medium.com/@vishwajeetv2003/the-reflection-pattern-how-self-critique-makes-ai-smarter-035df3b36aae
  why: Practical implementation patterns and prompt engineering
  section: "Structured Critique Prompts"

# Internal Documentation
- file: api/utils/retainer_letter_generator.py
  why: Current generator implementation - lines 262-340 generate_letter_content method

- file: api/utils/retainer_letter_generator.py
  why: Existing validation - lines 342-420 validate_legal_compliance method

- file: api/utils/legal_document_schemas.py
  why: LegalComplianceCheck model - lines 178-193 for validation structure

- file: api/index.py
  why: Main API endpoint - understand integration point

- file: api/utils/tools.py
  why: Tool function that calls generator - integration point

- docfile: PRPs/ai_docs/reflection-pattern-legal.md
  why: Comprehensive reflection pattern documentation for legal context
```

### Current Codebase Tree

```bash
api/
├── utils/
│   ├── retainer_letter_generator.py  # Main generator class
│   ├── legal_document_schemas.py     # Data models
│   ├── tools.py                      # Tool functions
│   └── pdf_generator.py              # PDF generation
├── tests/
│   └── test_simple_validation.py     # Basic tests
└── index.py                          # API endpoints
```

### Desired Codebase Tree with New Files

```bash
api/
├── services/                          # NEW: Service layer
│   ├── __init__.py
│   └── reflection_service.py         # Reflection pattern implementation
├── utils/
│   ├── retainer_letter_generator.py  # MODIFIED: Add reflection calls
│   └── reflection_prompts.py         # NEW: Structured critique prompts
├── models/                            # NEW: Reflection models
│   ├── __init__.py
│   └── reflection.py                 # Reflection data models
└── tests/
    ├── test_reflection_service.py    # NEW: Reflection tests
    └── test_reflection_integration.py # NEW: Integration tests
```

### Known Gotchas

```python
# CRITICAL: OpenAI streaming responses need complete capture before reflection
# Must wait for full response before starting critique

# CRITICAL: Token limits - reflection adds ~2000 tokens per iteration
# Monitor total token usage to stay within limits

# GOTCHA: Reflection can introduce inconsistencies
# Always validate final output matches original requirements

# PATTERN: Use temperature=0.1 for critique, 0.3 for refinement
# Lower temperature for analysis, slightly higher for generation

# GOTCHA: Don't reflect on reflection - avoid meta-loops
# Only reflect on document content, not on critique quality

# CRITICAL: Preserve original client information
# Reflection must not alter extracted client data
```

## Implementation Blueprint

### Data Models and Structure

```python
# api/models/reflection.py
from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any
from datetime import datetime

class DocumentCritique(BaseModel):
    """Structured critique of a legal document"""
    overall_score: float = Field(..., ge=0.0, le=1.0)
    strengths: List[str] = Field(default_factory=list)
    issues: List[Dict[str, str]] = Field(default_factory=list)  # {category, description, severity}
    missing_sections: List[str] = Field(default_factory=list)
    compliance_gaps: List[str] = Field(default_factory=list)
    language_improvements: List[str] = Field(default_factory=list)
    specific_corrections: Dict[str, str] = Field(default_factory=dict)  # {original: corrected}
    
class ReflectionIteration(BaseModel):
    """Single iteration of reflection process"""
    iteration_number: int
    input_content: str
    critique: DocumentCritique
    refined_content: str
    quality_delta: float  # Improvement from previous iteration
    processing_time_ms: int
    
class ReflectionResult(BaseModel):
    """Complete reflection process result"""
    original_content: str
    final_content: str
    iterations: List[ReflectionIteration]
    total_iterations: int
    initial_score: float
    final_score: float
    improvement_percentage: float
    total_processing_time_ms: int
    converged: bool  # Whether quality threshold was met
    convergence_reason: str  # "quality_met", "max_iterations", "no_improvement"
```

### List of Tasks (Dependency Order)

```yaml
Task 1: Create Reflection Data Models
CREATE api/models/__init__.py:
  - IMPORT pydantic BaseModel
  - EXPORT reflection models

CREATE api/models/reflection.py:
  - DEFINE DocumentCritique model
  - DEFINE ReflectionIteration model  
  - DEFINE ReflectionResult model
  - ADD validation for score ranges
  - ADD helper methods for metrics

Task 2: Implement Reflection Prompts
CREATE api/utils/reflection_prompts.py:
  - DEFINE get_critique_prompt function
  - DEFINE get_refinement_prompt function
  - INCLUDE jurisdiction-specific criteria
  - ADD legal compliance checklist
  - STRUCTURE evaluation categories

Task 3: Create Reflection Service
CREATE api/services/__init__.py:
  - IMPORT reflection_service

CREATE api/services/reflection_service.py:
  - IMPORT OpenAI client
  - IMPLEMENT critique_document method
  - IMPLEMENT refine_document method
  - IMPLEMENT reflection_loop method
  - ADD convergence detection
  - ADD performance tracking

Task 4: Integrate with Retainer Generator
MODIFY api/utils/retainer_letter_generator.py:
  - IMPORT reflection_service
  - ADD apply_reflection parameter
  - CALL reflection after initial generation
  - UPDATE validation_score with reflection score
  - TRACK improvement metrics
  - LOG reflection iterations

Task 5: Update Tool Function
MODIFY api/utils/tools.py:
  - ADD enable_reflection parameter
  - PASS reflection flag to generator
  - INCLUDE reflection metrics in response

Task 6: Create Reflection Tests
CREATE api/tests/test_reflection_service.py:
  - TEST critique generation
  - TEST refinement application
  - TEST convergence detection
  - TEST iteration limits
  - MOCK OpenAI calls

Task 7: Integration Testing
CREATE api/tests/test_reflection_integration.py:
  - TEST end-to-end reflection
  - TEST quality improvements
  - TEST performance impact
  - VERIFY original data preservation

Task 8: Update API Response
MODIFY api/utils/legal_document_schemas.py:
  - ADD reflection_applied field
  - ADD reflection_iterations field
  - ADD quality_improvement field
```

### Detailed Task Pseudocode

```python
# Task 2: Reflection Prompts Implementation
# api/utils/reflection_prompts.py

def get_critique_prompt(
    document_content: str,
    document_type: str,
    jurisdiction: str,
    matter_type: str
) -> str:
    """Generate structured critique prompt for legal document"""
    
    return f"""
    You are a senior legal compliance reviewer. Critically evaluate this {document_type} 
    for {jurisdiction} jurisdiction regarding {matter_type}.
    
    Document to Review:
    {document_content}
    
    Provide a detailed critique in JSON format:
    {{
        "overall_score": 0.75,  // 0.0 to 1.0
        "strengths": [
            "Clear fee structure",
            "Proper jurisdiction clause"
        ],
        "issues": [
            {{
                "category": "compliance",
                "description": "Missing required arbitration disclosure for {jurisdiction}",
                "severity": "high"
            }},
            {{
                "category": "clarity",
                "description": "Ambiguous termination clause in paragraph 5",
                "severity": "medium"  
            }}
        ],
        "missing_sections": [
            "Conflict of interest waiver",
            "Electronic communication consent"
        ],
        "compliance_gaps": [
            "{jurisdiction} Rule 1.5(b) fee agreement requirements not fully met"
        ],
        "language_improvements": [
            "Replace 'will try to' with 'shall' for enforceability",
            "Define 'reasonable time' with specific days"
        ],
        "specific_corrections": {{
            "retainer of $5000": "initial retainer of $5,000.00 (Five Thousand Dollars)",
            "various legal services": "legal services as specifically described in Section 2"
        }}
    }}
    
    Focus on:
    1. {jurisdiction}-specific legal requirements
    2. Professional responsibility rules compliance
    3. Clarity and enforceability of terms
    4. Protection of both client and attorney interests
    5. Completeness of required disclosures
    
    Be specific and actionable in your critique.
    """

def get_refinement_prompt(
    original_content: str,
    critique: DocumentCritique,
    jurisdiction: str
) -> str:
    """Generate refinement prompt based on critique"""
    
    issues_text = "\n".join([
        f"- {issue['category'].upper()}: {issue['description']}"
        for issue in critique.issues
    ])
    
    corrections_text = "\n".join([
        f"- Replace '{orig}' with '{corrected}'"
        for orig, corrected in critique.specific_corrections.items()
    ])
    
    return f"""
    Refine this legal document based on the following critique.
    Maintain all factual information about the client and matter.
    
    ORIGINAL DOCUMENT:
    {original_content}
    
    ISSUES TO ADDRESS:
    {issues_text}
    
    MISSING SECTIONS TO ADD:
    {', '.join(critique.missing_sections)}
    
    SPECIFIC CORRECTIONS:
    {corrections_text}
    
    LANGUAGE IMPROVEMENTS:
    {chr(10).join(critique.language_improvements)}
    
    COMPLIANCE REQUIREMENTS:
    {chr(10).join(critique.compliance_gaps)}
    
    Generate the improved document that:
    1. Addresses all identified issues
    2. Adds missing sections appropriately
    3. Applies all specific corrections
    4. Maintains professional legal tone
    5. Preserves all client information exactly
    6. Ensures {jurisdiction} compliance
    
    Output only the refined document without any commentary.
    """

# Task 3: Reflection Service Implementation
# api/services/reflection_service.py

class ReflectionService:
    def __init__(self, openai_client: OpenAI):
        self.openai_client = openai_client
        self.max_iterations = 3
        self.quality_threshold = 0.85
        self.min_improvement = 0.05
        
    async def reflection_loop(
        self,
        content: str,
        document_type: str,
        jurisdiction: str,
        matter_type: str
    ) -> ReflectionResult:
        """Main reflection loop with convergence detection"""
        
        iterations = []
        current_content = content
        previous_score = 0.0
        
        for i in range(self.max_iterations):
            # CRITIQUE current version
            critique = await self.critique_document(
                current_content, 
                document_type,
                jurisdiction,
                matter_type
            )
            
            # CHECK convergence criteria
            if critique.overall_score >= self.quality_threshold:
                converged = True
                convergence_reason = "quality_met"
                break
                
            if i > 0 and (critique.overall_score - previous_score) < self.min_improvement:
                converged = True
                convergence_reason = "no_improvement"
                break
            
            # REFINE based on critique
            refined_content = await self.refine_document(
                current_content,
                critique,
                jurisdiction
            )
            
            # RECORD iteration
            iteration = ReflectionIteration(
                iteration_number=i + 1,
                input_content=current_content,
                critique=critique,
                refined_content=refined_content,
                quality_delta=critique.overall_score - previous_score,
                processing_time_ms=0  # Track actual time
            )
            iterations.append(iteration)
            
            # UPDATE for next iteration
            current_content = refined_content
            previous_score = critique.overall_score
        else:
            converged = False
            convergence_reason = "max_iterations"
        
        # CALCULATE final metrics
        final_score = iterations[-1].critique.overall_score if iterations else 0.0
        initial_score = iterations[0].critique.overall_score if iterations else 0.0
        
        return ReflectionResult(
            original_content=content,
            final_content=current_content,
            iterations=iterations,
            total_iterations=len(iterations),
            initial_score=initial_score,
            final_score=final_score,
            improvement_percentage=(final_score - initial_score) * 100,
            total_processing_time_ms=sum(i.processing_time_ms for i in iterations),
            converged=converged,
            convergence_reason=convergence_reason
        )
    
    async def critique_document(
        self,
        content: str,
        document_type: str,
        jurisdiction: str,
        matter_type: str
    ) -> DocumentCritique:
        """Generate structured critique of document"""
        
        prompt = get_critique_prompt(content, document_type, jurisdiction, matter_type)
        
        response = await self.openai_client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a legal document compliance expert."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.1,  # Low temperature for consistent analysis
            max_tokens=1500
        )
        
        # PARSE response to DocumentCritique
        critique_json = json.loads(response.choices[0].message.content)
        return DocumentCritique(**critique_json)

# Task 4: Integration with Generator
# MODIFY api/utils/retainer_letter_generator.py

async def generate_retainer_letter(
    self,
    params: RetainerLetterParams,
    firm_settings: FirmSettings,
    user_id: str,
    apply_reflection: bool = True  # NEW parameter
) -> DocumentGenerationResult:
    """Generate retainer letter with optional reflection"""
    
    # ... existing generation code ...
    
    # Step 2: Generate initial retainer letter content
    letter_content = await self.generate_letter_content(
        client_info, 
        firm_settings, 
        params
    )
    
    # NEW: Step 2.5 - Apply reflection pattern if enabled
    if apply_reflection:
        logger.info(f"🔄 Applying reflection pattern for quality improvement")
        
        reflection_service = ReflectionService(self.openai_client)
        reflection_result = await reflection_service.reflection_loop(
            content=letter_content,
            document_type="retainer_letter",
            jurisdiction=firm_settings.default_jurisdiction,
            matter_type=client_info.matter_type
        )
        
        # Use refined content
        letter_content = reflection_result.final_content
        
        # Update metadata with reflection info
        generation_metadata["reflection_applied"] = True
        generation_metadata["reflection_iterations"] = reflection_result.total_iterations
        generation_metadata["quality_improvement"] = f"{reflection_result.improvement_percentage:.1f}%"
        generation_metadata["initial_score"] = reflection_result.initial_score
        generation_metadata["final_score"] = reflection_result.final_score
        
        # Use reflection score for validation
        compliance.score = reflection_result.final_score
    
    # Step 3: Continue with existing validation...
```

### Integration Points

```yaml
DATABASE:
  - No migration needed initially (metadata stored in JSONB)
  - Future: Add reflection_metrics table for analytics

CONFIG:
  - add to: api/core/config.py
  - pattern: "REFLECTION_ENABLED = os.getenv('REFLECTION_ENABLED', 'true').lower() == 'true'"
  - pattern: "REFLECTION_MAX_ITERATIONS = int(os.getenv('REFLECTION_MAX_ITERATIONS', '3'))"
  - pattern: "REFLECTION_QUALITY_THRESHOLD = float(os.getenv('REFLECTION_QUALITY_THRESHOLD', '0.85'))"

ENVIRONMENT:
  - add to: .env
  - REFLECTION_ENABLED=true
  - REFLECTION_MAX_ITERATIONS=3
  - REFLECTION_QUALITY_THRESHOLD=0.85

API:
  - Update tool function signature
  - Add reflection parameter to generate_retainer_letter tool
  - Include reflection metrics in response
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Python linting and type checking
cd api
ruff check services/ utils/ models/ --fix
mypy services/reflection_service.py models/reflection.py

# Expected: No errors. Fix any issues before proceeding.
```

### Level 2: Unit Tests

```python
# api/tests/test_reflection_service.py
import pytest
from unittest.mock import Mock, AsyncMock
from api.services.reflection_service import ReflectionService
from api.models.reflection import DocumentCritique

@pytest.mark.asyncio
async def test_critique_generation():
    """Critique correctly identifies document issues"""
    mock_openai = Mock()
    mock_response = Mock()
    mock_response.choices = [Mock(message=Mock(content=json.dumps({
        "overall_score": 0.7,
        "issues": [{"category": "compliance", "description": "Missing clause", "severity": "high"}],
        "missing_sections": ["Arbitration clause"],
        "compliance_gaps": [],
        "language_improvements": [],
        "specific_corrections": {}
    })))]
    
    mock_openai.chat.completions.create = AsyncMock(return_value=mock_response)
    
    service = ReflectionService(mock_openai)
    critique = await service.critique_document(
        "Sample document", "retainer_letter", "California", "contract"
    )
    
    assert critique.overall_score == 0.7
    assert len(critique.issues) == 1
    assert critique.issues[0]["severity"] == "high"

@pytest.mark.asyncio
async def test_convergence_quality_threshold():
    """Reflection stops when quality threshold met"""
    mock_openai = Mock()
    service = ReflectionService(mock_openai)
    service.quality_threshold = 0.85
    
    # Mock high-quality critique
    high_quality_critique = DocumentCritique(
        overall_score=0.9,
        issues=[],
        missing_sections=[]
    )
    
    service.critique_document = AsyncMock(return_value=high_quality_critique)
    service.refine_document = AsyncMock(return_value="Refined content")
    
    result = await service.reflection_loop(
        "Content", "retainer_letter", "California", "contract"
    )
    
    assert result.converged == True
    assert result.convergence_reason == "quality_met"
    assert result.total_iterations == 1

@pytest.mark.asyncio
async def test_max_iterations_limit():
    """Reflection stops at maximum iterations"""
    mock_openai = Mock()
    service = ReflectionService(mock_openai)
    service.max_iterations = 2
    
    # Mock low-quality critiques
    low_quality_critique = DocumentCritique(
        overall_score=0.6,
        issues=[{"category": "test", "description": "issue", "severity": "low"}],
        missing_sections=["Section"]
    )
    
    service.critique_document = AsyncMock(return_value=low_quality_critique)
    service.refine_document = AsyncMock(return_value="Refined content")
    
    result = await service.reflection_loop(
        "Content", "retainer_letter", "California", "contract"
    )
    
    assert result.converged == False
    assert result.convergence_reason == "max_iterations"
    assert result.total_iterations == 2
```

```bash
# Run tests
cd api
pytest tests/test_reflection_service.py -v
pytest tests/test_reflection_integration.py -v

# Coverage report
pytest tests/test_reflection_service.py --cov=services.reflection_service --cov-report=term-missing
```

### Level 3: Integration Test

```bash
# Start services
pnpm dev

# Test without reflection (baseline)
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_TOKEN" \
  -d '{
    "messages": [{
      "role": "user", 
      "content": "Generate a retainer letter for John Smith regarding a contract dispute"
    }],
    "tools": ["generate_retainer_letter"],
    "reflection_enabled": false
  }'

# Test with reflection enabled
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_TOKEN" \
  -d '{
    "messages": [{
      "role": "user", 
      "content": "Generate a retainer letter for John Smith regarding a contract dispute"
    }],
    "tools": ["generate_retainer_letter"],
    "reflection_enabled": true
  }'

# Compare quality scores and content between versions
```

### Level 4: Quality Validation

```python
# api/tests/test_quality_improvement.py
import pytest
from api.utils.retainer_letter_generator import RetainerLetterGenerator

@pytest.mark.asyncio
async def test_reflection_improves_quality():
    """Verify reflection actually improves document quality"""
    
    generator = RetainerLetterGenerator(openai_client)
    
    # Generate without reflection
    result_without = await generator.generate_retainer_letter(
        params, firm_settings, user_id, apply_reflection=False
    )
    
    # Generate with reflection
    result_with = await generator.generate_retainer_letter(
        params, firm_settings, user_id, apply_reflection=True
    )
    
    # Quality should improve
    assert result_with.validation_score > result_without.validation_score
    
    # Should have fewer compliance issues
    assert len(result_with.compliance_issues) <= len(result_without.compliance_issues)
    
    # Check specific improvements
    metadata = result_with.generation_metadata
    assert metadata.get("reflection_applied") == True
    assert float(metadata.get("quality_improvement", "0").rstrip("%")) > 0

# Benchmark test
@pytest.mark.benchmark
async def test_reflection_performance():
    """Ensure reflection doesn't exceed time limits"""
    import time
    
    start = time.time()
    result = await generator.generate_retainer_letter(
        params, firm_settings, user_id, apply_reflection=True
    )
    elapsed = time.time() - start
    
    # Should complete within 10 seconds even with reflection
    assert elapsed < 10.0
    assert result.processing_time_ms < 10000
```

## Final Validation Checklist

- [ ] All Python tests pass: `pytest api/tests/ -v`
- [ ] No linting errors: `ruff check api/`
- [ ] No type errors: `mypy api/`
- [ ] Reflection improves quality score by >20%
- [ ] Processing time increase < 5 seconds
- [ ] Convergence achieved in ≤3 iterations
- [ ] Original client data preserved exactly
- [ ] Compliance issues reduced by >25%
- [ ] All existing functionality still works
- [ ] Audit logs capture reflection metrics

## Anti-Patterns to Avoid

- ❌ Don't reflect on already high-quality documents (>0.9 score)
- ❌ Don't allow infinite reflection loops - enforce iteration limits
- ❌ Don't modify extracted client information during refinement
- ❌ Don't use high temperature for critique (keep at 0.1)
- ❌ Don't skip validation after reflection - always verify
- ❌ Don't reflect on reflection output - avoid meta-loops
- ❌ Don't ignore performance impact - track processing time

## Rollout Strategy

### Phase 1: Internal Testing (Day 1-2)
1. Deploy with reflection disabled by default
2. Enable for internal team accounts only
3. Compare quality metrics with/without reflection
4. Tune thresholds and iteration limits

### Phase 2: A/B Testing (Day 3-4)
1. Enable for 10% of users randomly
2. Track quality metrics and user feedback
3. Monitor performance impact
4. Adjust prompts based on results

### Phase 3: Full Rollout (Day 5-7)
1. Enable for all users by default
2. Add user preference to disable if desired
3. Monitor system performance
4. Collect feedback for future improvements

## Success Metrics

- Validation score improvement > 25%
- Compliance issues reduction > 30%
- User revision requests < 20% (down from 40%)
- Average iterations to convergence < 2.5
- Processing time increase < 5 seconds
- User satisfaction score > 4.5/5

## Monitoring & Alerts

```python
# Add monitoring for reflection system health
async def reflection_health_check():
    metrics = {
        'avg_iterations': await get_avg_iterations(),
        'convergence_rate': await calculate_convergence_rate(),
        'quality_improvement': await get_avg_improvement(),
        'processing_overhead': await calculate_overhead_ms(),
        'failure_rate': await get_reflection_failure_rate()
    }
    
    # Alert if issues
    if metrics['convergence_rate'] < 0.8:
        alert("Low convergence rate in reflection")
    
    if metrics['processing_overhead'] > 5000:
        alert("High reflection processing time")
    
    return metrics
```

## Future Enhancements

### Advanced Reflection (Phase 2)
- Multi-agent reflection with specialized reviewers
- Precedent-based validation against similar documents
- Learning from user corrections to improve critique

### External Validation (Phase 3)
- Integration with legal compliance APIs
- Jurisdiction-specific rule engines
- Real-time bar association guideline checking

### Continuous Learning (Phase 4)
- Store successful refinements as examples
- Fine-tune critique model on user feedback
- Adaptive thresholds based on document type

## Notes

The Reflection Pattern provides immediate value by catching issues that would typically require manual review. The implementation is designed to be incremental and non-disruptive, allowing us to enhance quality while maintaining system stability. The pattern's effectiveness in legal documents comes from the structured nature of legal requirements, making it ideal for systematic critique and improvement.
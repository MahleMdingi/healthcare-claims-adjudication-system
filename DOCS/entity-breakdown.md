# Entity Breakdown

## Members

Stores information about medical aid members registered on the system.

Key responsibilities:

* member personal information
* membership status tracking
* medical plan assignment
* registration and resignation tracking

---

## Dependants

Stores dependant information linked to main medical aid members.

Examples:

* spouse
* children
* parents

Key responsibilities:

* dependant relationship tracking
* dependant demographic information

---

## MedicalPlans

Stores information about available medical aid plans.

Key responsibilities:

* plan types
* monthly premiums
* coverage structure

Examples:

* Basic Plan
* Standard Plan
* Premium Plan

---

## Benefits

Defines the healthcare benefits available under each medical plan.

Key responsibilities:

* benefit categories
* annual limits
* coverage rules

Examples:

* Optical
* Dental
* Hospital
* Chronic Medication

---

## WaitingPeriods

Stores waiting period rules linked to benefits.

Key responsibilities:

* benefit waiting period enforcement
* coverage activation tracking

Example:

* Optical claims blocked for first 3 months

---

## Providers

Stores healthcare provider information.

Examples:

* doctors
* hospitals
* pharmacies
* specialists

Key responsibilities:

* provider validation
* provider classification
* practice number tracking

---

## Claims

Represents healthcare claims submitted to the medical aid system.

Key responsibilities:

* claim tracking
* claim status management
* provider linkage
* member/dependant linkage
* overall claim adjudication

---

## ClaimLines

Stores the individual procedures or services linked to a claim.

Key responsibilities:

* procedure-level claim processing
* tariff linkage
* approved vs claimed amount tracking
* line-level adjudication

Example:
A single claim may contain:

* consultation
* blood test
* medication

---

## Tariffs

Stores healthcare procedure and pricing information.

Key responsibilities:

* tariff code management
* procedure descriptions
* tariff pricing
* benefit category linkage

Examples:

* GP Consultation
* MRI Scan
* Blood Test
* X-Ray


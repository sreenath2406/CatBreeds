## AI Search Model – Testing Guide

This file describes the Core ML text classifier we use for search and how to test it.

- Training data: `Cat-Demo/Resources/cat_query_training.csv`
- Model file: `CatQueryClassifier.mlmodel`
- Labels:
  - `dog_friendly`
  - `child_friendly`
  - `grooming`

The `BreedsListViewModel` always searches locally over `allBreeds` and uses this model to understand the query.

---

### 1. Label semantics

- **`dog_friendly`**
- **`child_friendly`**
- **`grooming`**

At runtime we:
- Normalize the query (`trim + lowercased`).
- Ask `NLModel` for the top 3 label hypotheses.
- Pick the best label if its confidence ≥ `minConfidence` (currently **0.70**).
- Map label → `CatBreed` characteristic:
  - `dog_friendly` → `dogFriendly >= 4`
  - `child_friendly` → `childFriendly >= 4`
  - `grooming` → `grooming <= 2` (low maintenance)
- If confidence < threshold → fallback to **name search** over `breed.name`.

---

### 2. Sample keywords per label
#### 2.1 `dog_friendly`

Phrases that should hit the `dog_friendly` label:

- “good with dogs”
- “friendly with dogs”
- “cat that gets along with dogs”
- “cat that is good with dogs”
- “best cat for a home with dogs”
- “cat that can live with dogs”
- “dog compatible cat”
- “dog-friendly cat breed”
- “cat for a family with dogs”
- “cat for dog owners”
- “which cat breeds are good with dogs”
- “looking for a dog friendly cat”
- “need a cat that is dog friendly”
- “dog friendly cats”

#### 2.2 `child_friendly`

Phrases that should hit the `child_friendly` label:

- “good with kids”
- “good with children”
- “kid friendly cat”
- “child friendly cat”
- “family friendly cat”
- “best cat for kids”
- “cat safe for toddlers”
- “cat safe for babies”
- “gentle cat for kids”
- “patient cat with kids”
- “cat that tolerates kids”
- “cat that is calm around children”
- “cat good with small children”
- “cat breed good with kids”
- “best cat breed for families with kids”
- “need a kid friendly cat”

Trigger patterns are mostly around:

- `kid friendly *`
- `* for families with kids`
- `cat safe for * kids / toddlers / babies`

#### 2.3 `grooming`

Phrases that should hit the `grooming` label:

- “low maintenance cat”
- “cat that needs little grooming”
- “cat that needs minimal grooming”
- “easy to groom cat”
- “easy grooming cat”
- “low grooming cat breed”
- “cat with low grooming needs”
- “cat that doesn’t need much grooming”
- “cat that rarely needs brushing”
- “cat that requires little brushing”
- “cat with low upkeep”
- “cat that is not high maintenance”
- “best low maintenance cat breed”
- “easy care cat”
- “cat for busy owners”

---

### 3. How to test the AI search in the app

Assumes:
- First page fetch loads up to 100 breeds (so all breeds are available for filtering).

#### 3.1 Dog-friendly flow

1. Launch the app; wait until the breeds list is visible.
2. In the search bar, type: `dog friendly cats` (or any of the `dog_friendly` phrases above).
3. Expected behavior:
   - The table view displays **only breeds with `dogFriendly >= 4`**.

#### 3.2 Child-friendly flow

1. Clear the search text.
2. Type: `good with kids` or `kid friendly cat`.
3. Expected behavior:
   - UI shows breeds where `childFriendly >= 4`.

#### 3.3 Low-grooming / low-maintenance flow

1. Clear search.
2. Type: `low maintenance cat` or `easy to groom cat`.
3. Expected behavior:
   - UI shows breeds with `grooming <= 2` (low grooming requirement).

---
# Intuit Cat Breeds – Task Completed Notes

This is a short walkthrough of what I implemented and the architecture I followed.

## Architecture I Followed

I used a lightweight **MVVM + UseCase + Repository** structure.

The goal was to keep UI code simple, move business logic out of view controllers, and keep networking/data access behind clear abstractions.

### Layers

- **View (UIKit ViewController + Storyboard)**
  - Renders UI
  - Handles user interaction (tap, scroll, search input)
  - Does not contain networking logic

- **ViewModel**
  - Holds screen state and presentation logic
  - Talks to the view through delegate callbacks
  - Keeps UIKit out of core logic where possible (for example, returns rating image names instead of `UIImage`)

- **UseCase**
  - Small, focused application actions like:
    - fetching breeds by page
    - searching breeds by name
    - fetching breed image

- **Repository**
  - Data source abstraction for breeds and images
  - Hides endpoint details from higher layers

- **Networking**
  - `APIClient` handles request building, execution, decoding, and error mapping
  - Endpoint details live in one place (`CatAPIEndpoints`)

- **Composition Root**
  - `AppCompositionRoot` wires dependencies in one place
  - Makes dependency graph explicit and testable

## Why This Structure

I chose this setup because it stays:

- clearer separation of concerns
- easier to unit test without UI/network coupling
- fewer side effects in view controllers
- safer refactoring because responsibilities are explicit

## How the Required Features Were Implemented

### 1) Networking Enhancement (load all breeds, not just first subset)

- Implemented paginated loading in the breeds list flow.
- `BreedsListViewModel` keeps track of current page/end state and appends page results.
- Pagination is triggered by table scrolling (`willDisplay` on last row).
- This ensures the full dataset can be represented progressively instead of a single partial page.

### 2) Table View Content Update (name + description)

- The list cell text now includes both breed name and description.
- Data comes from decoded `CatBreed` model values and is rendered by the list view controller.

### 3) Detail View Implementation

- Added navigation from list to `BreedDetailsViewController` on row selection.
- Passed the selected `CatBreed` into `BreedDetailViewModel`.
- Detail screen shows metadata (core breed info + ratings + image + Wikipedia action).
- Image load is async with simple cache behavior in the detail ViewModel.

### 4) Filtering by Breed Name

- Implemented as **search** using Cat API search endpoint (`/v1/breeds/search?q=`).
- Added `UISearchController` on list screen.
- Added debounce in `BreedsListViewModel` to avoid firing a request on every keystroke.
- Search mode and browse mode are handled separately so pagination and search results do not conflict.
- Added empty state messaging for no-result searches.

## Testing Approach

I added unit tests for the main layers:

- ViewModels
- UseCases
- Repositories
- APIClient

Test structure is grouped by concern in `Cat-DemoTests`:

- `ViewModels`
- `UseCases`
- `Repositories`
- `Networking`
- `Support` (`Fixtures` + `SpyClasses`)

This keeps tests easy to navigate and aligns with the same architecture boundaries as production code.

## Note on Combine / SwiftUI

If this app was in SwiftUI, I would most likely use Combine for state updates.

Since this project is UIKit, I kept it straightforward:

- delegates to send updates from ViewModel to ViewController
- completion handlers for async work
- simple state handling in ViewModel (loading, pagination, search)

This keeps the flow clear and easy to review, without adding extra complexity.
# UI Rules

- Never use browser native pop-ups or hover tooltips — create styled alternatives matching the design system
- Pop-ups in tables/lists must have proper z-index (not overlapped by adjacent rows)
- Data-fetching components handle three states: loading (skeleton), empty, error
- All interactive elements keyboard accessible; images need alt text; inputs need labels
- Use semantic HTML (`nav`, `main`, `section`, `button`) — not `div` with click handlers
- Error messages: solid red background (`bg-red-600`) with white text, not subtle styling
- Open Graph meta tags for social sharing (title, description, image 1200x630px)
- Suggest splitting components exceeding 200 lines

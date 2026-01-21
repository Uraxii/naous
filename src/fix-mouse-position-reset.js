// Fix for GitHub issue #254: Mouse Position Resetting After Unhiding

// Function to store the mouse position
let mousePosition = { x: 0, y: 0 };

// Event listener to update mouse position
function updateMousePosition(event) {
  mousePosition.x = event.clientX;
  mousePosition.y = event.clientY;
}

document.addEventListener('mousemove', updateMousePosition);

// Function to restore mouse position after unhiding
function restoreMousePosition() {
  // Check if the element is hidden
  const element = document.getElementById('yourElementId');
  if (element && element.style.display === 'none') {
    // Unhide the element
    element.style.display = 'block';
    // Restore the mouse position
    window.scrollTo(mousePosition.x, mousePosition.y);
  }
}

// Example usage: Call restoreMousePosition when needed
// restoreMousePosition();
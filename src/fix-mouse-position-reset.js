// Fix for GitHub issue #254: Mouse Position Resetting After Unhiding

// Function to store the mouse position
let mousePosition = { x: 0, y: 0 };

// Event listener to update mouse position
document.addEventListener('mousemove', updateMousePosition);

function updateMousePosition(event) {
  mousePosition.x = event.clientX;
  mousePosition.y = event.clientY;
}

// Function to restore mouse position after unhiding
function restoreMousePosition() {
  const element = document.getElementById('yourElementId');
  if (element && element.style.display === 'none') {
    element.style.display = 'block';
    // Restore mouse position
    const mouseEvent = new MouseEvent('mousemove', {
      clientX: mousePosition.x,
      clientY: mousePosition.y
    });
    document.dispatchEvent(mouseEvent);
  }
}

// Example usage: Call restoreMousePosition when needed
// restoreMousePosition();
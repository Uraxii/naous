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
  if (element) {
    // Check if the element is hidden
    const isHidden = element.style.display === 'none';
    if (!isHidden) {
      // Restore mouse position
      const mouseEvent = new MouseEvent('mousemove', {
        clientX: mousePosition.x,
        clientY: mousePosition.y,
        bubbles: true
      });
      element.dispatchEvent(mouseEvent);
    }
  } else {
    console.error('Element with the specified ID not found.');
  }
}

// Example usage: Call restoreMousePosition when the element is unhidden
document.getElementById('yourElementId').addEventListener('transitionend', restoreMousePosition);
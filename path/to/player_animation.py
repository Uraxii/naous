```python
from naous.animations.base import BaseAnimation

class PlayerAnimations(BaseAnimation):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.animation_set = 'player_animations'
```

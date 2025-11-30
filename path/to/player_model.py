```python
from naous.models.base import BaseModel

class PlayerModel(BaseModel):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.model_name = 'new_player_model'
```

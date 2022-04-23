# Structiagram

```mermaid
%%{init: {
            "er": {
                "layoutDirection": "LR",
                "entityPadding": 15,
                "useMaxWidth": false
            }
        }}%%
erDiagram
B {
    String name
}
A {
    String name
    String created_at
    BId b
}
A ||--|| B : b
```

![Alt text](https://g.gravizo.com/svg?
  digraph G {
   es [shape=hexagon]
    universe [shape=hexagon]
    aspect_checker [shape=rect]
    systems [shape=folder label="systems\ns-tag set"]
    components [shape=folder label="components\nmap e-tag > cmp"]
    entities [shape=folder label="entities\ne-tag set"]
    system_manager [style=dashed]
    system [style=dashed]
    component_manager [style=dashed]
    component [style=dashed]
    entity_manager [style=dashed]
    entity [style=dashed]
    es -> universe
    universe -> {
      entity_manager
      component_manager
      system_manager
    } [dir=both]
    system_manager -> systems
    systems -> system
    component_manager -> components
    components -> component
    entity_manager -> entities
    entities -> entity
    entity -> {
      _components [shape=folder label="component\nflags"]
      _systems [shape=folder label="system\nflags"]
    }
  }
)

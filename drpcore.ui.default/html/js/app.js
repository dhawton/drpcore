(function() {
  let MenuTpl =
    '<div id="menu_{{_namespace}}_{{_name}}" class="menu{{#align}} align-{{align}}{{/align}}">' +
    '<div class="head"><span>{{{title}}}</span></div>' +
    '<div class="menu-items">' +
    "{{#elements}}" +
    '<div class="menu-item {{#selected}}selected{{/selected}}">' +
    "{{{label}}}{{#isSlider}} : &lt;{{{sliderLabel}}}&gt;{{/isSlider}}" +
    "</div>" +
    "{{/elements}}" +
    "</div>" +
    "</div>" +
    "</div>";
  window.DRP_MENU = {};
  DRP_MENU.ResourceName = "drpcore.ui.default";
  DRP_MENU.opened = {};
  DRP_MENU.focus = [];
  DRP_MENU.pos = {};

  DRP_MENU.open = function(namespace, name, data) {
    if (typeof DRP_MENU.opened[namespace] == "undefined")
      DRP_MENU.opened[namespace] = {};

    if (typeof DRP_MENU.opened[namespace][name] != "undefined")
      DRP_MENU.close(namespace, name);

    if (typeof DRP_MENU.pos[namespace] == "undefined")
      DRP_MENU.pos[namespace] = {};

    for (let i = 0; i < data.elements.length; i++)
      if (typeof data.elements[i].type == "undefined")
        data.elements[i].type = "default";

    data._index = DRP_MENU.focus.length;
    data._namespace = namespace;
    data._name = name;

    for (let i = 0; i < data.elements.length; i++) {
      data.elements[i]._namespace = namespace;
      data.elements[i]._name = name;
    }

    DRP_MENU.opened[namespace][name] = data;
    DRP_MENU.pos[namespace][name] = 0;

    for (let i = 0; i < data.elements.length; i++) {
      if (data.elements[i].selected) DRP_MENU.pos[namespace][name] = i;
      else data.elements[i].selected = false;
    }

    DRP_MENU.focus.push({
      namespace: namespace,
      name: name
    });

    DRP_MENU.render();

    $("#menu_" + namespace + "_" + name)
      .find(".menu-item.selected")[0]
      .scrollIntoView();
  };

  DRP_MENU.close = function(namespace, name) {
    delete DRP_MENU.opened[namespace][name];

    for (let i = 0; i < DRP_MENU.focus.length; i++) {
      if (
        DRP_MENU.focus[i].namespace == namespace &&
        DRP_MENU.focus[i].name == name
      ) {
        DRP_MENU.focus.splice(i, 1);
        break;
      }
    }

    DRP_MENU.render();
  };

  DRP_MENU.render = function() {
    let menuContainer = document.getElementById("menus");
    let focused = DRP_MENU.getFocused();
    menuContainer.innerHTML = "";

    $(menuContainer).hide();

    for (let namespace in DRP_MENU.opened) {
      for (let name in DRP_MENU.opened[namespace]) {
        let menuData = DRP_MENU.opened[namespace][name];
        let view = JSON.parse(JSON.stringify(menuData));

        for (let i = 0; i < menuData.elements.length; i++) {
          let element = view.elements[i];

          switch (element.type) {
            case "default":
              break;

            case "slider": {
              element.isSlider = true;
              element.sliderLabel =
                typeof element.options == "undefined"
                  ? element.value
                  : element.options[element.value];

              break;
            }

            default:
              break;
          }

          if (i == DRP_MENU.pos[namespace][name]) element.selected = true;
        }

        let menu = $(Mustache.render(MenuTpl, view))[0];

        $(menu).hide();

        menuContainer.appendChild(menu);
      }
    }

    if (typeof focused != "undefined")
      $("#menu_" + focused.namespace + "_" + focused.name).show();

    $(menuContainer).show();
  };

  DRP_MENU.submit = function(namespace, name, data) {
    SendMessage(DRP_MENU.ResourceName, "menu_submit", {
      _namespace: namespace,
      _name: name,
      current: data,
      elements: DRP_MENU.opened[namespace][name].elements
    });
  };

  DRP_MENU.cancel = function(namespace, name) {
    SendMessage(DRP_MENU.ResourceName, "menu_cancel", {
      _namespace: namespace,
      _name: name
    });
  };

  DRP_MENU.change = function(namespace, name, data) {
    SendMessage(DRP_MENU.ResourceName, "menu_change", {
      _namespace: namespace,
      _name: name,
      current: data,
      elements: DRP_MENU.opened[namespace][name].elements
    });
  };

  DRP_MENU.getFocused = function() {
    return DRP_MENU.focus[DRP_MENU.focus.length - 1];
  };

  window.onData = data => {
    switch (data.action) {
      case "openMenu": {
        DRP_MENU.open(data.namespace, data.name, data.data);
        break;
      }

      case "closeMenu": {
        DRP_MENU.close(data.namespace, data.name);
        break;
      }

      case "controlPressed": {
        switch (data.control) {
          case "ENTER": {
            let focused = DRP_MENU.getFocused();

            if (typeof focused != "undefined") {
              let menu = DRP_MENU.opened[focused.namespace][focused.name];
              let pos = DRP_MENU.pos[focused.namespace][focused.name];
              let elem = menu.elements[pos];

              if (menu.elements.length > 0)
                DRP_MENU.submit(focused.namespace, focused.name, elem);
            }

            break;
          }

          case "BACKSPACE": {
            let focused = DRP_MENU.getFocused();

            if (typeof focused != "undefined") {
              DRP_MENU.cancel(focused.namespace, focused.name);
            }

            break;
          }

          case "TOP": {
            let focused = DRP_MENU.getFocused();

            if (typeof focused != "undefined") {
              let menu = DRP_MENU.opened[focused.namespace][focused.name];
              let pos = DRP_MENU.pos[focused.namespace][focused.name];

              if (pos > 0) DRP_MENU.pos[focused.namespace][focused.name]--;
              else
                DRP_MENU.pos[focused.namespace][focused.name] =
                  menu.elements.length - 1;

              let elem =
                menu.elements[DRP_MENU.pos[focused.namespace][focused.name]];

              for (let i = 0; i < menu.elements.length; i++) {
                if (i == DRP_MENU.pos[focused.namespace][focused.name])
                  menu.elements[i].selected = true;
                else menu.elements[i].selected = false;
              }

              DRP_MENU.change(focused.namespace, focused.name, elem);
              DRP_MENU.render();

              $("#menu_" + focused.namespace + "_" + focused.name)
                .find(".menu-item.selected")[0]
                .scrollIntoView();
            }

            break;
          }

          case "DOWN": {
            let focused = DRP_MENU.getFocused();

            if (typeof focused != "undefined") {
              let menu = DRP_MENU.opened[focused.namespace][focused.name];
              let pos = DRP_MENU.pos[focused.namespace][focused.name];
              let length = menu.elements.length;

              if (pos < length - 1)
                DRP_MENU.pos[focused.namespace][focused.name]++;
              else DRP_MENU.pos[focused.namespace][focused.name] = 0;

              let elem =
                menu.elements[DRP_MENU.pos[focused.namespace][focused.name]];

              for (let i = 0; i < menu.elements.length; i++) {
                if (i == DRP_MENU.pos[focused.namespace][focused.name])
                  menu.elements[i].selected = true;
                else menu.elements[i].selected = false;
              }

              DRP_MENU.change(focused.namespace, focused.name, elem);
              DRP_MENU.render();

              $("#menu_" + focused.namespace + "_" + focused.name)
                .find(".menu-item.selected")[0]
                .scrollIntoView();
            }

            break;
          }

          case "LEFT": {
            let focused = DRP_MENU.getFocused();

            if (typeof focused != "undefined") {
              let menu = DRP_MENU.opened[focused.namespace][focused.name];
              let pos = DRP_MENU.pos[focused.namespace][focused.name];
              let elem = menu.elements[pos];

              switch (elem.type) {
                case "default":
                  break;

                case "slider": {
                  let min = typeof elem.min == "undefined" ? 0 : elem.min;

                  if (elem.value > min) {
                    elem.value--;
                    DRP_MENU.change(focused.namespace, focused.name, elem);
                  }

                  DRP_MENU.render();

                  break;
                }

                default:
                  break;
              }

              $("#menu_" + focused.namespace + "_" + focused.name)
                .find(".menu-item.selected")[0]
                .scrollIntoView();
            }

            break;
          }

          case "RIGHT": {
            let focused = DRP_MENU.getFocused();

            if (typeof focused != "undefined") {
              let menu = DRP_MENU.opened[focused.namespace][focused.name];
              let pos = DRP_MENU.pos[focused.namespace][focused.name];
              let elem = menu.elements[pos];

              switch (elem.type) {
                case "default":
                  break;

                case "slider": {
                  if (
                    typeof elem.options != "undefined" &&
                    elem.value < elem.options.length - 1
                  ) {
                    elem.value++;
                    DRP_MENU.change(focused.namespace, focused.name, elem);
                  }

                  if (typeof elem.max != "undefined" && elem.value < elem.max) {
                    elem.value++;
                    DRP_MENU.change(focused.namespace, focused.name, elem);
                  }

                  DRP_MENU.render();

                  break;
                }

                default:
                  break;
              }

              $("#menu_" + focused.namespace + "_" + focused.name)
                .find(".menu-item.selected")[0]
                .scrollIntoView();
            }

            break;
          }

          default:
            break;
        }

        break;
      }
    }
  };

  window.onload = function(e) {
    window.addEventListener("message", event => {
      onData(event.data);
    });
  };
})();

(function() {
  let MenuTpl =
    '<div id="menu_{{_namespace}}_{{_name}}" class="dialog {{#isBig}}big{{/isBig}}">' +
    '<div class="head"><span>{{title}}</span></div>' +
    '{{#isDefault}}<input type="text" name="value" id="inputText"/>{{/isDefault}}' +
    '{{#isBig}}<textarea name="value"/>{{/isBig}}' +
    '<button type="button" name="submit">Submit</button>' +
    '<button type="button" name="cancel">Cancel</button>';
  "</div>" + "</div>";

  window.DRP_MENU = {};
  DRP_MENU.ResourceName = "drpcore.ui.dialog";
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

    if (typeof data.type == "undefined") data.type = "default";

    if (typeof data.align == "undefined") data.align = "top-left";

    data._index = DRP_MENU.focus.length;
    data._namespace = namespace;
    data._name = name;

    DRP_MENU.opened[namespace][name] = data;
    DRP_MENU.pos[namespace][name] = 0;

    DRP_MENU.focus.push({
      namespace: namespace,
      name: name
    });

    document.onkeyup = function(key) {
      if (key.which == 27) {
        // Escape key
        $.post(
          "http://" + DRP_MENU.ResourceName + "/menu_cancel",
          JSON.stringify(data)
        );
      } else if (key.which == 13) {
        // Enter key
        $.post(
          "http://" + DRP_MENU.ResourceName + "/menu_submit",
          JSON.stringify(data)
        );
      }
    };

    DRP_MENU.render();
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
    let menuContainer = $("#menus")[0];

    $(menuContainer)
      .find('button[name="submit"]')
      .unbind("click");
    $(menuContainer)
      .find('button[name="cancel"]')
      .unbind("click");
    $(menuContainer)
      .find('[name="value"]')
      .unbind("input propertychange");

    menuContainer.innerHTML = "";

    $(menuContainer).hide();

    for (let namespace in DRP_MENU.opened) {
      for (let name in DRP_MENU.opened[namespace]) {
        let menuData = DRP_MENU.opened[namespace][name];
        let view = JSON.parse(JSON.stringify(menuData));

        switch (menuData.type) {
          case "default": {
            view.isDefault = true;
            break;
          }

          case "big": {
            view.isBig = true;
            break;
          }

          default:
            break;
        }

        let menu = $(Mustache.render(MenuTpl, view))[0];

        $(menu).css("z-index", 1000 + view._index);

        $(menu)
          .find('button[name="submit"]')
          .click(
            function() {
              DRP_MENU.submit(this.namespace, this.name, this.data);
            }.bind({ namespace: namespace, name: name, data: menuData })
          );

        $(menu)
          .find('button[name="cancel"]')
          .click(
            function() {
              DRP_MENU.cancel(this.namespace, this.name, this.data);
            }.bind({ namespace: namespace, name: name, data: menuData })
          );

        $(menu)
          .find('[name="value"]')
          .bind(
            "input propertychange",
            function() {
              this.data.value = $(menu)
                .find('[name="value"]')
                .val();
              DRP_MENU.change(this.namespace, this.name, this.data);
            }.bind({ namespace: namespace, name: name, data: menuData })
          );

        if (typeof menuData.value != "undefined")
          $(menu)
            .find('[name="value"]')
            .val(menuData.value);

        menuContainer.appendChild(menu);
      }
    }

    $(menuContainer).show();
    $("#inputText").focus();
  };

  DRP_MENU.submit = function(namespace, name, data) {
    $.post(
      "http://" + DRP_MENU.ResourceName + "/menu_submit",
      JSON.stringify(data)
    );
  };

  DRP_MENU.cancel = function(namespace, name, data) {
    $.post(
      "http://" + DRP_MENU.ResourceName + "/menu_cancel",
      JSON.stringify(data)
    );
  };

  DRP_MENU.change = function(namespace, name, data) {
    $.post(
      "http://" + DRP_MENU.ResourceName + "/menu_change",
      JSON.stringify(data)
    );
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
    }
  };

  window.onload = function(e) {
    window.addEventListener("message", event => {
      onData(event.data);
    });
  };
})();

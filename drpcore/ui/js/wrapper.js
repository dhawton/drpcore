(() => {
  let DRPWrapper = {};
  DRPWrapper.MessageSize = 1024;
  DRPWrapper.messageId = 0;

  window.SendMessage = function(namespace, type, msg) {
    DRPWrapper.messageId =
      DRPWrapper.messageId < 65535 ? DRPWrapper.messageId + 1 : 0;
    const str = JSON.stringify(msg);

    for (let i = 0; i < str.length; i++) {
      let count = 0;
      let chunk = "";

      while (count < DRPWrapper.MessageSize && i < str.length) {
        chunk += str[i];

        count++;
        i++;
      }

      i--;

      const data = {
        __type: type,
        id: DRPWrapper.messageId,
        chunk: chunk
      };

      if (i == str.length - 1) data.end = true;

      $.post("http://" + namespace + "/__chunk", JSON.stringify(data));
    }
  };
})();

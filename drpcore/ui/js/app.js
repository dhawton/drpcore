var characters = null;
var cadcharacters = null;
var selectedCharacter;
var leoWhitelisted = false;
var fireWhitelisted = false;
var leoGrade = -1;
var fireGrade = -1;
var job;

function loadloading(txt) {
  resetScreens();
  $("#loading").css("display", "block");
  $("#loadingMsg").html(txt || "Loading...");
}

function loadSelect() {
  resetScreens();
  $("#characterSelect").css("display", "block");
}
function loadCreate() {
  resetScreens();
  $("#characterCreate").css("display", "block");
  if (leoWhitelisted) {
    $("#createdept[value='highway']").prop("disabled", false);
    $("#createdept[value='sheriff']").prop("disabled", false);
    $("#createdept[value='police']").prop("disabled", false);
  }
  if (fireWhitelisted) {
    $("#createdept[value='fire']").prop("disabled", false);
  }
}

function loadLEODept() {
  resetScreens();
  $("#selectLEODept").css("display", "block");
}

function loadFireDept() {
  resetScreens();
  $("#selectFireDept").css("display", "block");
}

function loadSpawnLSPD() {
  resetScreens();
  $("#selectStationLEO").css("display", "block");
}

function loadSpawnCiv() {
  resetScreens();
  $("#selectStationCiv").css("display", "block");
}

function loadCharacterEdit() {
  resetScreens();
  $("#characterEdit").css("display", "block");
  if (leoWhitelisted) {
    $("#editcreatedept[value='highway']").prop("disabled", false);
    $("#editcreatedept[value='sheriff']").prop("disabled", false);
    $("#editcreatedept[value='police']").prop("disabled", false);
  }
  if (fireWhitelisted) {
    $("#editcreatedept[value='fire']").prop("disabled", false);
  }
}

function resetScreens() {
  $("#loading").css("display", "none");
  $("#characterSelect").css("display", "none");
  $("#characterCreate").css("display", "none");
  $("#characterEdit").css("display", "none");
  $("#selectStationLEO").css("display", "none");
  $("#selectStationCiv").css("display", "none");
  $("#selectLEODept").css("display", "none");
  $("selectFireDept").css("display", "none");
}

function displayCharacters() {
  $("#characterbody").empty();
  if (characters.length == 0) {
    $("#characterbody").append("No characters available, please create one.");
  } else if (characters != null) {
    for (var i = 0; i < characters.length; i++) {
      var _cad = cadcharacters.characters.filter(
        c =>
          c.firstname.toUpperCase() === characters[i].firstname.toUpperCase() &&
          c.lastname.toUpperCase() === characters[i].lastname.toUpperCase()
      )[0];
      let html = `
        <tr class="${_cad === undefined ? "bg-red" : ""}">
          <td>${_cad !== undefined ? _cad.idnumber : "NOT REGISTERED"}</td>
          <td>${characters[i].firstname} ${characters[i].lastname}</td>
          <td>${characters[i].label_job} ${
        characters[i].label_job !== "Unemployed"
          ? ` - ${characters[i].label_grade}`
          : ""
      }</td>
          <td>${_cad !== undefined ? _cad.address : "NOT REGISTERED"}</td>
          <td>${_cad !== undefined ? _cad.licensestatus : "NOT REGISTERED"}</td>
          <td>
          <button class="btn btn-success btnSelectCharacter" type="button" onClick="selectCharacter(${
            characters[i].id
          })">
          <i class="fas fa-sign-in-alt"></i>
          </button>
          <button class="btn btn-warning btnEditCharacter" type="button"
              onClick="editCharacter(${characters[i].id})">
                  <i class="far fa-edit"></i>
              </button>
              <button class="btn btn-danger btnEditCharacter" type="button"
              onClick="deleteCharacter(${characters[i].id})">
              <i class="far fa-trash-alt"></i>
              </button>
            </td>
          </tr>
      `;
      $("#characterbody").append(html);
    }
  }
}

window.addEventListener("message", function(event) {
  if (event.data.type == "DH_SEND_CHARACTERS") {
    characters = event.data.data.characters;
    leoWhitelisted = event.data.data.leowhitelisted;
    leoGrade = event.data.data.leograde;
    fireWhitelisted = event.data.data.firewhitelisted;
    fireGrade = event.data.data.firegrade;
    if (characters !== null && cadcharacters !== null) {
      loadSelect();
      displayCharacters();
    }
  } else if (event.data.type == "DH_SEND_CHARACTERS_CAD") {
    cadcharacters = event.data.data.data;
    if (characters !== null && cadcharacters !== null) {
      loadSelect();
      displayCharacters();
    }
  } else if (event.data.type == "DH_DISABLE_ALL_UI") {
    loadloading();
  } else if (event.data.type == "SHOW") {
    $("body").attr(
      "style",
      "background-color: rgba(0,20,40,1.0); color: #fff;"
    );
    $("#container").show();
    loadloading();
  } else if (event.data.type == "DH_DISABLE_UI") {
    resetScreens();
    $("body").attr("style", "background: none");
    $("#container").hide();
    $("#drp").hide();
    $("#logo").hide();
  }
});

function editCharacter(id) {
  var character = characters.filter(c => c.id === id)[0];
  var jobname = character.job_name;
  if (
    (character.job_name === "highway" ||
      character.job_name === "sheriff" ||
      character.job_name === "police") &&
    leoWhitelisted === false
  ) {
    jobname = "civ";
  }
  if (character.job_name === "fire" && fireWhitelisted === false) {
    jobname = "civ";
  }
  if (
    character.job_name !== "highway" &&
    character.job_name !== "sheriff" &&
    character.job_name !== "police" &&
    character.job_name !== "fire"
  ) {
    jobname = "civ";
  }
  $("#editfirstname").val(character.firstname);
  $("#editlastname").val(character.lastname);
  $("#editid").val(character.id);
  $('#editcreatedept[value="' + jobname + '"]').prop("checked", true);
  loadCharacterEdit();
}

function saveCharacter() {
  let id = $("#editid").val();
  let firstname = $("#editfirstname").val();
  let lastname = $("#editlastname").val();
  let dept = $("#editcreatedept:checked").val();
  if (firstname == "" || lastname == "" || dept == "") {
    return;
  }

  $.post(
    "http://drpcore/editCharacter",
    JSON.stringify({ id, firstname, lastname, dept })
  ).then(function() {
    resetScreens();
  });
}

function createCharacter() {
  let firstname = $("#firstname").val();
  let lastname = $("#lastname").val();
  let dept = $("#createdept:checked").val();
  if (firstname == "" || lastname == "" || dept == "") {
    return;
  }

  $.post(
    "http://drpcore/createCharacter",
    JSON.stringify({ firstname, lastname, dept })
  ).then(function() {
    resetScreens();
  });
}

function deleteCharacter(id) {
  resetScreens();
  $.post("http://drpcore/deleteCharacter", JSON.stringify({ id }));
}

function selectCharacter(id) {
  selectedCharacter = characters.filter(c => c.id === id)[0];
  if (
    selectedCharacter.job_name === "highway" ||
    selectedCharacter.job_name === "sheriff" ||
    selectedCharacter.job_name === "police"
  ) {
    loadLEODept();
  } else if (selectedCharacter.job_name === "fire") {
    loadFireDept();
  } else {
    loadSpawnCiv();
  }
}

$(".btnCreateCharacter").click(function() {
  loadCreate();
});

function selectDept(d) {
  selectedCharacter.job_name = d;
  loadSpawnLSPD();
}

function selectStation(station) {
  console.log(
    JSON.stringify({ character: selectedCharacter, station: station })
  );
  $.post(
    "http://drpcore/selectCharacter",
    JSON.stringify({ character: selectedCharacter, station: station })
  );
  resetScreens();
}

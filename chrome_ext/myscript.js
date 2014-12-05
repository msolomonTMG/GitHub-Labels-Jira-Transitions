/*
//Creating Elements
var btn = document.createElement("BUTTON")
var t = document.createTextNode("CLICK ME");
btn.appendChild(t);
//Appending to DOM 
document.body.appendChild(btn);
*/


//this is where we are going to put the button
var buttonList = document.getElementsByClassName('gh-header-actions')[0];
buttonList.style.width="236px";
/*
//some styling
var buttonListWrapper = document.createElement("DIV");
buttonListWrapper.className = "buttonListWrapper";
buttonListWrapper.appendChild(buttonList);
var buttonListRow = document.getElementsByClassName('gh-header-show')[0];
buttonListRow.appendChild(buttonListWrapper);
*/
//container for staging button
var stagingButtonContainer = document.createElement("DIV");
stagingButtonContainer.className = "select-menu js-menu-container js-select-menu";
buttonList.insertBefore(stagingButtonContainer,buttonList.firstChild);

//create staging button, then add it to the container
var stagingButton = document.createElement("A");
stagingButton.className = "minibutton select-menu-button js-menu-target";
stagingButton.setAttribute("href","#");
stagingButton.setAttribute("role","button");
stagingButton.setAttribute("tabindex","0");
stagingButton.setAttribute("aira-haspopup","true");
stagingButtonContainer.appendChild(stagingButton);

//create a span with the cloud icon, "Stage" and dropdown caret then add it to button
var selectButton = document.createElement("SPAN");
selectButton.className = "js-select-button";
selectButton.appendChild(document.createTextNode(" Stage "));

var selectButtonIcon = document.createElement("SPAN");
selectButtonIcon.className = "octicon octicon-cloud-upload";
selectButton.appendChild(selectButtonIcon);
selectButton.insertBefore(selectButtonIcon,selectButton.firstChild);
stagingButton.appendChild(selectButton);

//create the dropdown container
var buttonMenu = document.createElement("DIV");
buttonMenu.className = "select-menu-modal-holder";
buttonMenu.style.marginTop="25px";
buttonMenu.style.marginLeft="5px";
stagingButtonContainer.appendChild(buttonMenu);

//this holds all dropdown content
var buttonMenuContent = document.createElement("DIV");
buttonMenuContent.className = "select-menu-modal subscription-menu-modal js-menu-content"
buttonMenuContent.setAttribute("aria-hidden","true");
buttonMenu.appendChild(buttonMenuContent);

//header of the dropdown
var buttonMenuContentHeader = document.createElement("DIV");
buttonMenuContentHeader.className = "select-menu-header";
buttonMenuContent.appendChild(buttonMenuContentHeader);

  var buttonMenuContentHeaderTitle = document.createElement("SPAN");
  buttonMenuContentHeaderTitle.className = "select-menu-title";
  buttonMenuContentHeaderTitle.appendChild(document.createTextNode("Staging Servers"));
  buttonMenuContentHeader.appendChild(buttonMenuContentHeaderTitle);

  var buttonMenuContentHeaderClose = document.createElement("SPAN");
  buttonMenuContentHeaderClose.className = "octicon octicon-x js-menu-close";
  buttonMenuContentHeaderClose.setAttribute("role","button");
  buttonMenuContentHeaderClose.setAttribute("aria-label","Close");
  buttonMenuContentHeader.appendChild(buttonMenuContentHeaderClose);

var buttonMenuContentBody = document.createElement("DIV");
buttonMenuContentBody.className = "select-menu-list js-navigation-container js-active-navigation-container";
buttonMenuContentBody.setAttribute("role","menu");
buttonMenuContent.appendChild(buttonMenuContentBody);

  var buttonMenuItem1 = document.createElement("DIV");
  buttonMenuItem1.className = "select-menu-item js-navigation-item";
  buttonMenuItem1.setAttribute("role","menuitem");
  buttonMenuItem1.setAttribute("tabindex","0");
  buttonMenuContentBody.appendChild(buttonMenuItem1);

    var buttonMenuItem1Icon = document.createElement("SPAN");
    buttonMenuItem1Icon.className = "select-menu-item-icon octicon octicon-check";
    buttonMenuItem1.appendChild(buttonMenuItem1Icon);

    var buttonMenuItem1Title = document.createElement("DIV");
    buttonMenuItem1Title.className = "select-menu-item-text";
    buttonMenuItem1.appendChild(buttonMenuItem1Title);

      var buttonMenuItem1Input = document.createElement("INPUT");
      buttonMenuItem1Input.type = "radio";
      buttonMenuItem1Input.name = "do";
      buttonMenuItem1Input.value = "included";
      buttonMenuItem1Input.id = "do_included";
      buttonMenuItem1.appendChild(buttonMenuItem1Input);

      var buttonMenuItem1TitleContent = document.createElement("H4");
      buttonMenuItem1TitleContent.innerHTML = "Stage 01";
      buttonMenuItem1Title.appendChild(buttonMenuItem1TitleContent);

      var buttonMenuItem1TitleDescription = document.createElement("SPAN");
      buttonMenuItem1TitleDescription.className = "description";
      buttonMenuItem1TitleDescription.appendChild(document.createTextNode("ms-TL-TE-515-ad_fixes"));
      buttonMenuItem1Title.appendChild(buttonMenuItem1TitleDescription);

      var buttonMenuItem1TitleHidden = document.createElement("SPAN");
      buttonMenuItem1TitleHidden.className = "js-select-button-text hidden-select-button-text";
      buttonMenuItem1Title.appendChild(buttonMenuItem1TitleHidden);

        var buttonMenuItem1TitleHiddenIcon = document.createElement("SPAN");
        buttonMenuItem1TitleHiddenIcon.className = "octicon octicon-sync spin";
        buttonMenuItem1TitleHidden.appendChild(buttonMenuItem1TitleHiddenIcon);
        buttonMenuItem1TitleHidden.appendChild(document.createTextNode(" Staging "));

  var buttonMenuItem2 = document.createElement("DIV");
  buttonMenuItem2.className = "select-menu-item js-navigation-item";
  buttonMenuItem2.setAttribute("role","menuitem");
  buttonMenuItem2.setAttribute("tabindex","0");
  buttonMenuContentBody.appendChild(buttonMenuItem2);

    var buttonMenuItem2Icon = document.createElement("SPAN");
    buttonMenuItem2Icon.className = "select-menu-item-icon octicon octicon-check";
    buttonMenuItem2.appendChild(buttonMenuItem2Icon);

    var buttonMenuItem2Title = document.createElement("DIV");
    buttonMenuItem2Title.className = "select-menu-item-text";
    buttonMenuItem2.appendChild(buttonMenuItem2Title);

      var buttonMenuItem2Input = document.createElement("INPUT");
      buttonMenuItem2Input.type = "radio";
      buttonMenuItem2Input.name = "do";
      buttonMenuItem2Input.value = "included";
      buttonMenuItem2Input.id = "do_included";
      buttonMenuItem2.appendChild(buttonMenuItem2Input);

      var buttonMenuItem2TitleContent = document.createElement("H4");
      buttonMenuItem2TitleContent.innerHTML = "Stage 02";
      buttonMenuItem2Title.appendChild(buttonMenuItem2TitleContent);

      var buttonMenuItem2TitleDescription = document.createElement("SPAN");
      buttonMenuItem2TitleDescription.className = "description";
      buttonMenuItem2TitleDescription.appendChild(document.createTextNode("bm-TL-TE-566-checkout_stuff "));
      buttonMenuItem2Title.appendChild(buttonMenuItem2TitleDescription);

      var buttonMenuItem2TitleDescriptionLabel = document.createElement("A");
      buttonMenuItem2TitleDescriptionLabel.setAttribute("href","#");
      buttonMenuItem2TitleDescriptionLabel.className = "label linked-labelstyle-009800";
      buttonMenuItem2TitleDescriptionLabel.title = "QAed";
      buttonMenuItem2TitleDescriptionLabel.innerHTML = "QAed";
      buttonMenuItem2TitleDescription.appendChild(buttonMenuItem2TitleDescriptionLabel);

      var buttonMenuItem2TitleHidden = document.createElement("SPAN");
      buttonMenuItem2TitleHidden.className = "js-select-button-text hidden-select-button-text";
      buttonMenuItem2Title.appendChild(buttonMenuItem2TitleHidden);

        var buttonMenuItem2TitleHiddenIcon = document.createElement("SPAN");
        buttonMenuItem2TitleHiddenIcon.className = "octicon octicon-sync spin";
        buttonMenuItem2TitleHidden.appendChild(buttonMenuItem2TitleHiddenIcon);
        buttonMenuItem2TitleHidden.appendChild(document.createTextNode(" Staging "));

  var buttonMenuItem3 = document.createElement("DIV");
  buttonMenuItem3.className = "select-menu-item js-navigation-item";
  buttonMenuItem3.setAttribute("role","menuitem");
  buttonMenuItem3.setAttribute("tabindex","0");
  buttonMenuContentBody.appendChild(buttonMenuItem3);

    var buttonMenuItem3Icon = document.createElement("SPAN");
    buttonMenuItem3Icon.className = "select-menu-item-icon octicon octicon-check";
    buttonMenuItem3.appendChild(buttonMenuItem3Icon);

    var buttonMenuItem3Title = document.createElement("DIV");
    buttonMenuItem3Title.className = "select-menu-item-text";
    buttonMenuItem3.appendChild(buttonMenuItem3Title);

      var buttonMenuItem3Input = document.createElement("INPUT");
      buttonMenuItem3Input.type = "radio";
      buttonMenuItem3Input.name = "do";
      buttonMenuItem3Input.value = "included";
      buttonMenuItem3Input.id = "do_included";
      buttonMenuItem3.appendChild(buttonMenuItem3Input);

      var buttonMenuItem3TitleContent = document.createElement("H4");
      buttonMenuItem3TitleContent.innerHTML = "Stage 03";
      buttonMenuItem3Title.appendChild(buttonMenuItem3TitleContent);

      var buttonMenuItem3TitleDescription = document.createElement("SPAN");
      buttonMenuItem3TitleDescription.className = "description";
      buttonMenuItem3TitleDescription.appendChild(document.createTextNode("gc-TL-TE-515-hotfix_for_sticky_headers "));
      buttonMenuItem3Title.appendChild(buttonMenuItem3TitleDescription);

      var buttonMenuItem3TitleDescriptionLabel = document.createElement("A");
      buttonMenuItem3TitleDescriptionLabel.setAttribute("href","#");
      buttonMenuItem3TitleDescriptionLabel.className = "label linked-labelstyle-009800";
      buttonMenuItem3TitleDescriptionLabel.title = "QAed";
      buttonMenuItem3TitleDescriptionLabel.innerHTML = "QAed";
      buttonMenuItem3TitleDescription.appendChild(buttonMenuItem3TitleDescriptionLabel);

      var buttonMenuItem3TitleHidden = document.createElement("SPAN");
      buttonMenuItem3TitleHidden.className = "js-select-button-text hidden-select-button-text";
      buttonMenuItem3Title.appendChild(buttonMenuItem3TitleHidden);

        var buttonMenuItem3TitleHiddenIcon = document.createElement("SPAN");
        buttonMenuItem3TitleHiddenIcon.className = "octicon octicon-sync spin";
        buttonMenuItem3TitleHidden.appendChild(buttonMenuItem3TitleHiddenIcon);
        buttonMenuItem3TitleHidden.appendChild(document.createTextNode(" Staging "));

  var buttonMenuItem4 = document.createElement("DIV");
  buttonMenuItem4.className = "select-menu-item js-navigation-item";
  buttonMenuItem4.setAttribute("role","menuitem");
  buttonMenuItem4.setAttribute("tabindex","0");
  buttonMenuContentBody.appendChild(buttonMenuItem4);

    var buttonMenuItem4Icon = document.createElement("SPAN");
    buttonMenuItem4Icon.className = "select-menu-item-icon octicon octicon-check";
    buttonMenuItem4.appendChild(buttonMenuItem4Icon);

    var buttonMenuItem4Title = document.createElement("DIV");
    buttonMenuItem4Title.className = "select-menu-item-text";
    buttonMenuItem4.appendChild(buttonMenuItem4Title);

      var buttonMenuItem4Input = document.createElement("INPUT");
      buttonMenuItem4Input.type = "radio";
      buttonMenuItem4Input.name = "do";
      buttonMenuItem4Input.value = "included";
      buttonMenuItem4Input.id = "do_included";
      buttonMenuItem4.appendChild(buttonMenuItem4Input);

      var buttonMenuItem4TitleContent = document.createElement("H4");
      buttonMenuItem4TitleContent.innerHTML = "Stage 04";
      buttonMenuItem4Title.appendChild(buttonMenuItem4TitleContent);

      var buttonMenuItem4TitleDescription = document.createElement("SPAN");
      buttonMenuItem4TitleDescription.className = "description";
      buttonMenuItem4TitleDescription.appendChild(document.createTextNode("ts-TL-TE-601-hotness_hiding_under_stack_overlay "));
      buttonMenuItem4Title.appendChild(buttonMenuItem4TitleDescription);

      var buttonMenuItem4TitleDescriptionLabel = document.createElement("A");
      buttonMenuItem4TitleDescriptionLabel.setAttribute("href","#");
      buttonMenuItem4TitleDescriptionLabel.className = "label linked-labelstyle-009800";
      buttonMenuItem4TitleDescriptionLabel.title = "QAed";
      buttonMenuItem4TitleDescriptionLabel.innerHTML = "QAed";
      //buttonMenuItem4TitleDescription.appendChild(buttonMenuItem4TitleDescriptionLabel);

      var buttonMenuItem4TitleHidden = document.createElement("SPAN");
      buttonMenuItem4TitleHidden.className = "js-select-button-text hidden-select-button-text";
      buttonMenuItem4Title.appendChild(buttonMenuItem4TitleHidden);

        var buttonMenuItem4TitleHiddenIcon = document.createElement("SPAN");
        buttonMenuItem4TitleHiddenIcon.className = "octicon octicon-server";
        buttonMenuItem4TitleHidden.appendChild(buttonMenuItem4TitleHiddenIcon);
        buttonMenuItem4TitleHidden.appendChild(document.createTextNode(" Staged "));
        buttonList.style.width="245px";

/*
var edit = document.getElementsByClassName('minibutton js-details-target')[0];
edit.style.float="right";
var newIssue = document.getElementsByClassName('minibutton primary')[0];
newIssue.style.float="right";
*/

var style = document.createElement('link');
style.rel = 'stylesheet';
style.type = 'text/css';
style.href = chrome.extension.getURL('mycss.css');
(document.head||document.documentElement).appendChild(style);

//document.getElementsByClassName('gh-header-actions')[0].appendChild(stagingButton);

/*
var liHeaderNavItem = document.createElement("LI");
liHeaderNavItem.className = "header-nav-item dropdown js-menu-container";

var aHeaderNavLink = document.createElement("A");
aHeaderNavLink.className = "header-nav-link js-menu-target tooltipped tooltipped-s";
aHeaderNavLink.setAttribute("href","#");
aHeaderNavLink.setAttribute("aria-label","Deploy to...");

var spanOcticonPlus = document.createElement("SPAN");
spanOcticonPlus.className = "octicon octicon-cloud-upload";

var spanDownCaret = document.createElement("SPAN");
spanDownCaret.className = "dropdown-caret";

//aHeaderNavLink.appendChild(spanOcticonPlus);
aHeaderNavLink.appendChild(spanDownCaret);
liHeaderNavItem.appendChild(aHeaderNavLink);

stagingButton.appendChild(liHeaderNavItem);

var buttonList = document.getElementsByClassName('gh-header-actions')[0];
buttonList.insertBefore(stagingButton,buttonList.firstChild);
//document.getElementsByClassName('gh-header-actions')[0].appendChild(liHeaderNavItem);

/*
  <li class="header-nav-item dropdown js-menu-container">
    
    <a class="header-nav-link js-menu-target tooltipped tooltipped-s" href="#" aria-label="Create new..." data-ga-click="Header, create new, icon:add">
      <span class="octicon octicon-plus"></span>
      <span class="dropdown-caret"></span>
    </a>

    <div class="dropdown-menu-content js-menu-content">
      
      <ul class="dropdown-menu">
        <li>
          <a href="/new"><span class="octicon octicon-repo"></span> New repository</a>
        </li>
        <li>
          <a href="/organizations/new"><span class="octicon octicon-organization"></span> New organization</a>
        </li>

        <li class="dropdown-divider"></li>

        <li class="dropdown-header">
          <span title="Thrillist/Pinnacle">This repository</span>
        </li>
        <li>
          <a href="/Thrillist/Pinnacle/issues/new"><span class="octicon octicon-issue-opened"></span> New issue</a>
        </li>
      </ul>
    </div>
  </li>
  */

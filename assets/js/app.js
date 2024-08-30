import {socket, channel} from "./socket"

let running = false;

function setHeaders(repoId, container) {
    let row = $(`<tr></tr>`).appendTo(`.${repoId} .${container} table thead`);

    $(`<th scope="col"><strong>State</strong></th>`).appendTo(row);
    $(`<th scope="col"><strong>Version</strong></th>`).appendTo(row);
    $(`<th scope="col"><strong>Name</strong></th>`).appendTo(row);
    $(`<th scope="col"><strong>&nbsp;</strong></th>`).appendTo(row);
}

function drawRows(repo, repoId, migrations, type) {

    $(`.${repoId} .${(type == "migrations") ? 'migrations' : 'pending'} table thead`).html("");
    $(`.${repoId} .${(type == "migrations") ? 'migrations' : 'pending'} table tbody`).html("");

    if (migrations.length > 0) {
        setHeaders(repoId, (type == "migrations") ? 'migrations' : 'pending');

        for (let i in migrations) {
            let auto_href = $(`<a>${(type == "migrations") ? 'Rollback' : 'Migrate'}</a>`).attr({
                class: "migrate-link btn btn-danger",
                href: "javascript:void(0)",
                "data-migration": (type == "migrations") ? 'rollback' : 'migrate',
                "data-repo": repo,
                "data-timestamp": migrations[i][0]
            });

            let manual_href = $(`<a>${(type == "migrations") ? 'Unmark as Migrated' : 'Mark as Migrated'}</a>`).attr({
                class: "migrate-link btn btn-warning",
                href: "javascript:void(0)",
                "data-migration": (type == "migrations") ? 'manual_rollback' : 'manual_migrate',
                "data-repo": repo,
                "data-timestamp": migrations[i][0]
            });

            let row = $(`<tr></tr>`).appendTo(`.${repoId} .${(type == "migrations") ? 'migrations' : 'pending'} table tbody`);

            $(`<td>${(type == "migrations") ? 'up' : 'down'}</td>`).appendTo(row);
            $(`<td><a href="#" data-toggle="modal" data-target="#version_${migrations[i][0]}">${migrations[i][0]}</a></td>`).appendTo(row);
            $(`<td>${(type == "migrations") ? 'n/a' : migrations[i][2]}</td>`).appendTo(row);

            let controls_div = $(`<div class="btn-group" role="group" aria-label="Basic example"></div>`).append(auto_href).append(manual_href);
            $(`<td width="300"></td>`).append(controls_div).appendTo(row);

            $(`<div class="modal fade" id="version_${migrations[i][0]}" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true"><div class="vertical-alignment-helper"><div class="modal-dialog vertical-align-center modal-lg"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button><h4 class="modal-title" id="myModalLabel">Version ${migrations[i][0]} Code</h4></div><div class="modal-body"><pre><code>${migrations[i][1]}</code></pre></div></div></div></div></div>`)
            .appendTo(row);
        }
    } else {
        let row = $(`<tr></tr>`).appendTo(`.${repoId} .${(type == "migrations") ? 'migrations' : 'pending'} table thead`);
        $(`<th colspan="4">There are no ${(type == "migrations") ? '' : 'pending '}migrations</th>`).appendTo(row);
    }

    $("a.migrate-link").removeClass("disabled");
}

$(document).ready(function(){
    channel.push("migration", {status: "get"});
});

$(document).on("click", "a.migrate-link", function(){

    if ($(this).data('migration') == "rollback") {
        if (false === confirm("This action will rollback this migration and all newer ones (above this one)! Do you want to proceed?")) {
            return;
        }
    } else if ($(this).data('migration') == "migrate") {
        if (false === confirm("This action will apply this migration and all older ones (below this one)! Do you want to proceed?")) {
            return;
        }
    } else {
        if (false === confirm("I confirm this migartion has been done/reverted by DBA! Proceed?")) {
            return;
        }
    }

    channel.push("migration", {migration: $(this).data('migration'), repo: $(this).data('repo'), timestamp: $(this).data('timestamp')});

    $(this).html("Running...").show();
    $("a.migrate-link").addClass("disabled");
    running = true;
});

$(document).on("mouseover", "a.migrate-link.btn-danger", function(){
    if (running) {
        return;
    }

    let current = $(this);
    let all = $(this).parent().parent().parent().parent().parent().parent().find("a.migrate-link.btn-danger");

    if ($(this).parent().parent().parent().parent().parent().parent().attr("class") == "pending") {
        all.html("Migrate");
        for (let i = all.index(current); i <= all.length; i++) {
            $(all[i]).html("⇑");
        }
    } else {
        all.html("Rollback");
        for (let i = all.index(current); i >= 0; i--) {
            $(all[i]).html("⇓");
        }
    }
});

$(document).on("mouseout", "a.migrate-link.btn-danger", function(){
    if (running) {
        return;
    }

    let all = $(this).parent().parent().parent().parent().parent().parent().find("a.migrate-link.btn-danger");
    if ($(this).parent().parent().parent().parent().parent().parent().attr("class") == "pending") {
        all.html("Migrate");
    } else {
        all.html("Rollback");
    }
});

channel.on("running", message => {
    if (message.running === true) {
        $("a.migrate-link").addClass("disabled");
        $(".overlay").show();
        running = true;
    }
});

channel.on("status", message => {
    drawRows(message.repo, message.repoId, message.migrated, "migrations");
    drawRows(message.repo, message.repoId, message.pending, "pending");

    $(".overlay").hide();
    running = false;

    if (message.error_msg != "") {
        alert(message.error_msg);
    }
});

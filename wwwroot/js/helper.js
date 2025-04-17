var helper = {};

// To remove data tampering characters
/*helper.sanitizeInput = function(input) {
    return input.replace(/[<>;"'(){}$%&+]/g, '');
}*/

/*helper.sanitizeInput = function (input) {
    return input.replace(/[<>]/g, function (char) {
        return char === '<' ? '&lt;' : '&gt;';
    });
};*/

helper.stripHTML = function (input) {
    return input.replace(/<.*?>/g, '');
}

helper.DateForamt1 = function (inDate) {
    var ret = dayjs(inDate).format('DD-MMM-YYYY');
    return ret;
}
helper.DateForamt2 = function (inDate) {
    if (!inDate) return "Invalid Date";
    var ret = dayjs(inDate).format('DD-MMM-YYYY hh:mm a');
    return ret;
}
helper.DateForamt3 = function (inDate) {
    var ret = dayjs(inDate).format('YYYY-MM-DD');
    return ret;
}
helper.DateForamt4 = function (inDate) {
    if (!inDate) return "Invalid Date";
    var ret = dayjs(inDate).format('DD-MMM-YYYY HH:mm');
    return ret;
}

helper.ToLocalDate = function (inDate) {
    if (_.isUndefined(inDate)) return;
    inDate = inDate.replace("T", " ");
    inDate = inDate + " UTC";
    var date = new Date(inDate);
    return date;
}
helper.ToLocalDate2 = function (inDate) {
    return dayjs.utc(helper.ToLocalDate(inDate)).local().format('DD-MMM-YYYY HH:mm');
}

helper.ToLocalDate3 = function (inDate) {
    return dayjs(helper.ToLocalDate(inDate)).format('DD-MMM-YYYY hh:mm a');
}
helper.ToLocalDate4 = function (inDate) {
    return helper.DateForamt4(dayjs(inDate).toDate());
}

const ToastMessages = {
    SUCCESS: {
        SAVE_SUCCESS: "Data Saved",
        UPDATE_SUCCESS: "Data Updated",
        DELETE_SUCCESS: "Data Deleted",
        ROW_SAVED: "Row Saved",
        ROW_DELETED: "Row Deleted",
        ROW_REMOVED: "Row Removed",
        APPROVAL_SUCCESS: "Approved",
        REJECTED_SUCCESS: "Rejected",
        NOTIFY_SUCCESS: "Email Send",
        
    },
    ERROR: {
        SAVE_FAIL: "Save Unsuccessful",
        ANGLE_FAIL: "< or > not allowed",
        REJECTED_FAIL: "Failed to Reject",
        LOAD_FAIL: "Failed to Load Data",
        VALIDATE: "Fill all required fields",
        MISSING_DATES: "Select Start & End Date",
        UPDATE_FAIL: "Update Failed",
        DELETE_FAIL: "Delete Failed",
        TASK_EXIST:"Task Already Exist",
    }
};

helper.SuccessToast = function (msg) {
    const notification = ToastMessages.SUCCESS[msg] || msg;
    $.toast({
        displayTime: 5000,
        message: notification,
        class: 'success',
        showProgress: 'bottom'
    })
}

helper.ErrorToast = function (msg) {
    const notification = ToastMessages.ERROR[msg] || msg;
    $.toast({
        displayTime: 5000,
        message: notification,
        class: 'error',
        showProgress: 'bottom'
    })
}

helper.toTable = function (json) {
    var tbl = '<table class="ui celled padded table">';
    tbl += '<thead><tr>';
    _.each(_.keys(json[0]), function (k) {
        tbl += '<th>' + k + '</th>';
    });
    tbl += '</tr></thead>';

    _.each(json, function (row) {
        tbl += '<tr>';
        _.each(_.keys(json[0]), function (k) {
            tbl += '<td>' + row[k] + '</td>';
        });
        tbl += '</tr>';
    });
    tbl += '</table>';
    return tbl;
};

helper.ShowModal = function (content) {
    $("#mdlContent").html(content);
    $('#mdlBasic')
        .modal('show')
        ;
}

helper.ShowAuditModal = function (Id, page) {
    var url = window.location.origin + "/Widgets/Admin/VersionHistoryModal?Id=" + Id + "&t=" + page;
    $.ajax({
        url: url,
        success: function (result) {
            $("#mdlContentFullScreen").html(result);
            $('#mdlBasicFullScreen').modal('show');
        },
        error: function (err) {
            console.error('Error: ', err);
        }
    });

}

helper.RecruiterProfilePath = function (recruiter) {

    var profilepath = '/images/Profile/user.png';
    if (_.size(_.where(objData.Recruiters, { ShortName: recruiter })) > 0) {
        profilepath = _.first(_.where(objData.Recruiters, { ShortName: recruiter })).ProfilePath;
    }
    return profilepath;
}
helper.DisplayRecruiter = function (recruiter, length) {
    profilepath = helper.RecruiterProfilePath(recruiter);

    var str = '';
    length != 0 ? str += `<a class="ui teal large label" style="width:${length}px" onclick=Javascript:helper.ShowRecruiterModal("` + recruiter + `")>` : str += `<a class="ui teal large label">`;
    str += '<img class="ui right spaced avatar image" src="' + profilepath + '">' + recruiter + '</a>';
    return str;
}

helper.ShowRecruiterModal = function (recruiter) {

    var url = window.location.origin + "/recruitermodalpage?r=" + recruiter;
    $.ajax({
        url: url,
        success: function (result) {
            $("#mdlContentFullScreen").html(result);
            $('#mdlBasicFullScreen')
                .modal('show')
                ;
        }
    }
    );
}

helper.formatRelativeTime = function (dateString) {
    dateString = helper.ToLocalDate2(dateString);
    const now = new Date();
    const createdDate = new Date(dateString);
    const diffInMs = now - createdDate;
    const diffInMinutes = Math.floor(diffInMs / 60000);
    const diffInHours = Math.floor(diffInMinutes / 60);
    const diffInDays = Math.floor(diffInHours / 24);

    if (diffInMinutes < 1) {
        return 'just now';
    } else if (diffInMinutes < 60) {
        return `${diffInMinutes} min${diffInMinutes > 1 ? 's' : ''} ago`;
    } else if (diffInHours < 24) {
        return `${diffInHours} hour${diffInHours > 1 ? 's' : ''} ago`;
    } else if (diffInDays <= 5) {
        return `${diffInDays} day${diffInDays > 1 ? 's' : ''} ago`;
    } else {
        return helper.DateForamt2(dateString); // Shows date and time for older notifications
    }
}

helper.formatRelativeTime2 = function (dateString) {
    dateString = helper.ToLocalDate2(dateString);
    const now = new Date();
    const createdDate = new Date(dateString);
    const diffInMs = now - createdDate;
    const diffInMinutes = Math.floor(diffInMs / 60000);
    const diffInHours = Math.floor(diffInMinutes / 60);
    const diffInDays = Math.floor(diffInHours / 24);
    const diffInWeeks = Math.floor(diffInDays / 7);
    const diffInMonths = Math.floor(diffInDays / 30);

    if (diffInMinutes < 1) {
        return 'just now';
    } else if (diffInMinutes < 60) {
        return `${diffInMinutes} min${diffInMinutes > 1 ? 's' : ''} ago (${dateString})`;
    } else if (diffInHours < 24) {
        return `${diffInHours} hour${diffInHours > 1 ? 's' : ''} ago (${dateString})`;
    } else if (diffInDays <= 7) {
        return `${diffInDays} day${diffInDays > 1 ? 's' : ''} ago (${dateString})`;
    } else if (diffInWeeks <= 4) {
        return `${diffInWeeks} week${diffInWeeks > 1 ? 's' : ''} ago (${dateString})`;
    } else if (diffInMonths <= 12) {
        return `${diffInMonths} month${diffInMonths > 1 ? 's' : ''} ago (${dateString})`;
    } else {
        return helper.DateForamt2(dateString); // Shows date and time for older notifications
    }
}


helper.getInitials = function(displayName) {
    const nameParts = displayName.trim().split(/\s+/);

    if (nameParts.length === 1) {
        return nameParts[0].substring(0, 2).toUpperCase();
    }

    const firstInitial = nameParts[0][0];
    const lastInitial = nameParts[nameParts.length - 1][0];

    // Combine and convert to uppercase
    return (firstInitial + lastInitial).toUpperCase();
}

helper.getRandomColor = function () {
    const colors = [
        'red', 'yellow', 'olive',
        'green', 'teal', 'blue', 'brown'
    ];

    return colors[Math.floor(Math.random() * colors.length)];
}
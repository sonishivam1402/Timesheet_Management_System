var notification = {};

notification.loadNotifications = function () {
    $.ajax({
        url: '/api/notification',
        type: 'GET',
        success: (notifications) => {
            $('#notificationList').empty();
            notifications.forEach((item, index) => {
                const relativeTime = helper.formatRelativeTime(item.createdOn);
                const backgroundColor = index % 2 === 0 ? '#ffffff' : '#f2f2f2';


                const $item = $(`
                    <div class="item notification-item ${!item.isRead ? 'read' : ''} ${!item.isRead ? 'new' : ''}" style="background-color: ${backgroundColor}" data-id="${item.recordId}">
                        ${!item.isRead ? '<div class="new-indicator"></div>' : ''}
                        <i class="large ${item.icon} middle aligned icon"></i>
                        <div class="content">
                            <div class="title">${item.title}</div>
                            <div class="meta">${relativeTime}</div>
                            <div class="description" style="font-size:0.8em !important;">${item.description}</div>
                        </div>
                        <div class="notification-actions">
                            <i class="times circle outline red icon delete-notification" title="Dismiss notification" style="font-size: 1.25em; "></i>
                        </div>
                    </div>
                `);

                $('#notificationList').append($item);
                

            });
        },
        error: (xhr) => {
            console.log("Error loading notifications:", xhr.responseText);
        }
    });
};


notification.resetNotificationCount = function () {
    $.ajax({
        url: '/api/notification/count',
        type: 'GET',
        success: (data) => {
            $('#notificationCount').text(data.notificationCount);
            
        },
        error: (xhr) => {
            console.log("Error resetting count:", xhr.responseText);
        }
    });
};

notification.markAllAsRead = function () {
    $.ajax({
        url: '/api/notification/read',
        type: 'POST',
        success: () => {
            notification.loadNotifications(); // Refresh the list after marking as read
        },
        error: (xhr) => {
            console.log("Error marking notifications as read:", xhr.responseText);
        }
    });
};






$(document).ready(() => {
    const $notificationPopup = $('#notificationPopup');
    const $notificationButton = $('#notificationButton');
    const $notificationCount = $('#notificationCount');

    // Fetch notifications and count on popup open
    $notificationButton.popup({
        popup: $notificationPopup,
        on: 'click',
        position: 'bottom center',
        lastResort: 'bottom center',
        onShow: () => {
            notification.loadNotifications();
            notification.resetNotificationCount();
            
        },
        onHide: () => {
            notification.markAllAsRead();
            notification.resetNotificationCount();
        }
    });

    

    // Mark notification as inactive (delete action)
    $(document).on('click', '.delete-notification', function (e) {
        e.stopPropagation();
        const $item = $(this).closest('.notification-item');
        const recordId = $item.data('id');

        $.ajax({
            url: `/api/notification/inactive/${recordId}`,
            type: 'POST',
            success: () => {
                $item.remove();
                notification.resetNotificationCount();
            },
            error: (xhr) => {
                console.log("Error marking notification as inactive:", xhr.responseText);
            }
        });
    });

    // Polling for new notifications every 30 seconds
    setInterval(() => {
        notification.resetNotificationCount();
    }, 20000);
});

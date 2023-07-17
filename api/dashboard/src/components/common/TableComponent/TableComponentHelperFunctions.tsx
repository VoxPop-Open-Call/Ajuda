import React from "react";

import { CBadge } from "@coreui/react-pro";

import styles from "./tablecomponent.module.scss";

export const userColumns = [
  {
    key: "name",
    _props: { className: styles.headerStyle },
  },
  {
    key: "email",
    _props: { className: styles.headerStyle },
  },
  {
    key: "verified",
    label: "Status",
    _props: { className: styles.headerStyle },
  },
  {
    key: "actions",
    label: "",
    filter: false,
    sorter: false,
    _style: { width: "1%" },
    _props: { className: styles.headerStyle },
  },
];

export const requestColumns = [
  { key: "requester", _props: { className: styles.headerStyle } },
  {
    key: "volunteer",
    label: "Volunteer",
    _props: { className: styles.headerStyle },
  },
  {
    key: "taskType",
    label: "Request Type",
    _props: { className: styles.headerStyle },
  },
  {
    key: "date",
    label: "Request Date",
    _props: { className: styles.headerStyle },
  },
  { key: "rate", _props: { className: styles.headerStyle } },
  {
    key: "actions",
    label: "",
    filter: false,
    sorter: false,
    _style: { width: "1%" },
    _props: { className: styles.headerStyle },
  },
];

export const contentColumns = [
  { key: "title", _props: { className: styles.headerStyle } },
  {
    key: "subject",
    label: "Category",
    _props: { className: styles.headerStyle },
  },
  {
    key: "date",
    label: "Date",
    _props: { className: styles.headerStyle },
  },
  { key: "state", label: "Status", _props: { className: styles.headerStyle } },
  {
    key: "actions",
    label: "",
    filter: false,
    sorter: false,
    _style: { width: "1%" },
    _props: { className: styles.headerStyle },
  },
];

export const verifiedColumnBadge = (
  userVerifiedStatus: boolean
): JSX.Element => {
  let badgeText = "";
  let badgeColour = "";
  if (userVerifiedStatus) {
    badgeText = "Verified";
    badgeColour = "success";
  } else {
    badgeText = "Not Verified";
    badgeColour = "warning";
  }
  return (
    <td>
      <CBadge color={badgeColour}>{badgeText}</CBadge>
    </td>
  );
};

export const stateColumnBadge = (contentStateStatus: string): JSX.Element => {
  let badgeText,
    badgeStyle = styles.rejectedVerifiedStatusBadgeStyle;
  switch (contentStateStatus) {
    case "approved":
      badgeText = "Approved";
      badgeStyle = styles.verifiedStatusBadgeStyle;
      break;
    case "pending":
      badgeText = "Pending";
      badgeStyle = styles.notVerifiedStatusBadgeStyle;
      break;
    default:
      badgeText = "Rejected";
  }
  return (
    <td>
      <div className={badgeStyle}>{badgeText}</div>
    </td>
  );
};

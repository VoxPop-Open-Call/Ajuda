import React, { PropsWithChildren } from "react";

import {
  cilAddressBook,
  cilBell,
  cilChart,
  cilCog,
  cilNewspaper,
  cilPeople,
  cilSpeedometer,
  cilStar,
} from "@coreui/icons";
import CIcon from "@coreui/icons-react";
import { CNavItem } from "@coreui/react";

import "./sidebarRoutes.module.scss";

export interface NavGroupComponentProps {
  idx?: string;
  key?: string | number | null;
  toggler: JSX.Element;
  visible: boolean;
}

export interface NavItemComponentProps {
  to: string;
  items?: object;
}

export interface NavGroupItemProps {
  component: React.ComponentType<PropsWithChildren<NavGroupComponentProps>>;
  name: string;
  icon: JSX.Element;
  to: string;
  items?: Array<NavGroupItemProps | NavItemProps>;
}

export interface NavItemProps {
  component: React.ComponentType<PropsWithChildren<NavItemComponentProps>>;
  name: string;
  badge?: { color: string; text: string };
  icon: JSX.Element;
  to: string;
  items?: object;
}

const sidebarRoutes: Array<NavGroupItemProps | NavItemProps> = [
  {
    component: CNavItem,
    name: "Dashboard",
    to: "/dashboard",
    // icon: <CTooltip content="Dashboard">Dashboard</CTooltip>,
    icon: <CIcon icon={cilSpeedometer} customClassName="nav-icon" />,
  },
  {
    component: CNavItem,
    name: "Volunteers",
    to: "/volunteers",
    icon: <CIcon icon={cilStar} customClassName="nav-icon" />,
  },
  {
    component: CNavItem,
    name: "Users",
    to: "/users",
    icon: <CIcon icon={cilPeople} customClassName="nav-icon" />,
  },
  {
    component: CNavItem,
    name: "Requests",
    to: "/requests",
    icon: <CIcon icon={cilAddressBook} customClassName="nav-icon" />,
  },
  {
    component: CNavItem,
    name: "Analytics",
    to: "/analytics",
    icon: <CIcon icon={cilChart} customClassName="nav-icon" />,
  },
  {
    component: CNavItem,
    name: "Notifications",
    to: "/notifications",
    icon: <CIcon icon={cilBell} customClassName="nav-icon" />,
  },
  {
    component: CNavItem,
    name: "News",
    to: "/news",
    icon: <CIcon icon={cilNewspaper} customClassName="nav-icon" />,
  },
  {
    component: CNavItem,
    name: "Settings",
    to: "/settings",
    icon: <CIcon icon={cilCog} customClassName="nav-icon" />,
  },
];

export default sidebarRoutes;

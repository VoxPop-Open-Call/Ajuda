import React from "react";

import { Navigate, Outlet, RouteObject } from "react-router-dom";

import Analytics from "./views/pages/analytics/Analytics";
import ContentDetailsManager from "./views/pages/contentManagement/ContentDetailsManager";
import ContentManagement from "./views/pages/contentManagement/ContentManagement";
import Dashboard from "./views/pages/dashboard/Dashboard";
import FaqManager from "./views/pages/FAQ/FaqManager";
import Login from "./views/pages/login/Login";
import MainLayout from "./views/pages/MainLayout/MainLayout";
import PageNotImplemented from "./views/pages/PageNotImplemented/PageNotImplemented";
import PolicyManager from "./views/pages/policy/PolicyManager";
import Requests from "./views/pages/requests/Requests";
import TermsAndConditionsManager from "./views/pages/terms_and_conditions/TermsAndConditionsManager";
import UserDetailsManager from "./views/pages/users/UserDetailsManager";
import Users from "./views/pages/users/Users";
import Volunteers from "./views/pages/volunteers/Volunteers";

function routes(
  isLoggedIn: boolean,
  isLoggedInFunction: React.Dispatch<React.SetStateAction<boolean>>
): Array<RouteObject> {
  return [
    {
      element: isLoggedIn ? (
        <MainLayout onLoggedChange={isLoggedInFunction} />
      ) : (
        <Navigate to="/login" />
      ),
      children: [
        { path: "/dashboard", element: <Dashboard /> },
        { path: "/users", element: <Users /> },
        { path: "/user/:id", element: <UserDetailsManager /> },
        { path: "/volunteers", element: <Volunteers /> },
        { path: "/requests", element: <Requests /> },
        { path: "/news", element: <ContentManagement /> },
        { path: "/news/:id", element: <ContentDetailsManager /> },
        { path: "/analytics", element: <Analytics /> },
        { path: "/", element: <Navigate to="/dashboard" replace /> },
        { path: "*", element: <PageNotImplemented /> },
      ],
    },
    {
      element: !isLoggedIn ? <Outlet /> : <Navigate to="/dashboard" />,
      children: [
        {
          path: "login",
          element: <Login onLoggedChange={isLoggedInFunction} />,
        },
        { path: "/", element: <Navigate to="/login" /> },
      ],
    },
    { path: "terms-conditions", element: <TermsAndConditionsManager /> },
    {
      path: "policy",
      element: <PolicyManager />,
    },
    {
      path: "/faq",
      element: <FaqManager />,
    },
  ];
}

export default routes;

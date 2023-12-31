import React from "react";

import { useLocation } from "react-router";

import PolicyEN from "./PolicyEN";
import PolicyPT from "./PolicyPT";

const PolicyManager = (): JSX.Element => {
  const location = useLocation();
  const params = new URLSearchParams(location.search);
  const selectedLang = params.get("lang");
  const renderPolicy = (): JSX.Element => {
    switch (selectedLang) {
      case "pt":
      case "PT":
        return <PolicyPT />;
      default:
        return <PolicyEN />;
    }
  };
  return renderPolicy();
};

export default PolicyManager;

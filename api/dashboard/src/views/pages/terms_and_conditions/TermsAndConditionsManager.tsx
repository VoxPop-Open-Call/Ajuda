import React from "react";

import { useLocation } from "react-router";

import TermsAndConditionsEN from "./TermsAndConditionsEN";
import TermsAndConditionsPT from "./TermsAndConditionsPT";

const TermsAndConditionsManager = (): JSX.Element => {
  const location = useLocation();
  const params = new URLSearchParams(location.search);
  const selectedLang = params.get("lang");
  const renderTermsAndServices = (): JSX.Element => {
    switch (selectedLang) {
      case "pt":
      case "PT":
        return <TermsAndConditionsPT />;
      default:
        return <TermsAndConditionsEN />;
    }
  };
  return renderTermsAndServices();
};

export default TermsAndConditionsManager;

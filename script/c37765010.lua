--苍穹魔女 芙蕾
function c37765010.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37765010,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,37765010)
	e1:SetCondition(c37765010.spcon)
	e1:SetTarget(c37765010.sptg)
	e1:SetOperation(c37765010.spop)
	c:RegisterEffect(e1)
	--run
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c37765010.rmop)
	c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37765010,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,37765010+1)
	e3:SetCondition(c37765010.thcon)
	e3:SetTarget(c37765010.thtg)
	e3:SetOperation(c37765010.thop)
	c:RegisterEffect(e3)
end
function c37765010.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
function c37765010.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c37765010.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
end
function c37765010.cfilter(c)
	return c:IsSetCard(0x2a4) and c:IsType(TYPE_QUICKPLAY) and c:IsFaceup()
end
function c37765010.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(c37765010.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or not c:IsAbleToRemove() then return end
	Duel.Hint(HINT_CARD,0,37765010)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetLabelObject(c)
	e1:SetOperation(c37765010.retop)
	Duel.RegisterEffect(e1,tp)
end
function c37765010.retop(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsActiveType(TYPE_QUICKPLAY) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(0x2a4)) then return end
	Duel.Hint(HINT_CARD,0,37765010)
	Duel.ReturnToField(e:GetLabelObject())
	e:Reset()
end
function c37765010.chkfilter(c)
	local typ=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)
	return typ&TYPE_MONSTER~=0
end
function c37765010.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37765010.chkfilter,1,nil)
end
function c37765010.thfilter(c,chk)
	return c:IsSetCard(0x2a4) and c:IsAbleToHand() and (chk==0 or aux.NecroValleyFilter()(c))-- and c:IsFaceupEx() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c37765010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37765010.thfilter,tp,LOCATION_DECK,0,1,nil,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c37765010.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c37765010.thfilter,tp,LOCATION_DECK,0,1,1,nil,1):GetFirst()
	if not tc then return end
	--Duel.HintSelection(Group.FromCards(tc))
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	--if not tc:IsLocation(LOCATION_HAND) or not Duel.SelectYesNo(tp,aux.Stringid(37765010,2)) then return end
end

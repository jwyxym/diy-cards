--绝叫的扩散
function c38030155.initial_effect(c)
	aux.AddCodeList(c,38030161)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38030155+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38030155.target)
	e1:SetOperation(c38030155.activate)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030155)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38030155.damtg)
	e2:SetOperation(c38030155.damop)
	c:RegisterEffect(e2)
end
function c38030155.spfilter(c,e,tp,chk)
	return c:IsCode(38030161) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (chk==0 or aux.NecroValleyFilter()(c))-- and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsType(TYPE_MONSTER)
end
function c38030155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.IsExistingMatchingCard(c38030155.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,2,nil,e,tp,0)
	end--
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function c38030155.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,c38030155.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,2,2,nil,e,tp,1)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c38030155.damfilter(c)
	return c:IsSetCard(0x5616) and c:IsFaceup() and c:GetAttack()>0
end
function c38030155.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38030155.damfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c38030155.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c38030155.damfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function c38030155.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end

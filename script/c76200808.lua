--血商的鲜血交易
local s,id,o=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true

--by chocobeak↓
function c76200808.spfilter(c,e,tp,chk)
	local lv=c:GetLevel()
	return c:IsSetCard(0x704) and lv>=3 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:IsType(TYPE_FUSION) and Duel.IsCanRemoveCounter(tp,1,1,0x1704,math.floor(lv/3)*2,REASON_EFFECT) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0--(chk==1 or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
function c76200808.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		and Duel.IsExistingMatchingCard(c76200808.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c76200808.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local fc=Duel.SelectMatchingCard(tp,c76200808.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,1):GetFirst()
	if not fc then return end
	Duel.ConfirmCards(1-tp,fc)
	local ct=math.floor(fc:GetLevel()/3)*2
	if Duel.RemoveCounter(tp,1,1,0x1704,ct,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		fc:SetMaterial(nil)
		Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		fc:CompleteProcedure()
	end
end

function s.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1704)>0
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end

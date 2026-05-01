--血商的强制清算
local s,id,o=GetID()
function s.initial_effect(c)
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

--by chocobeak↓
function c76200814.spfilter(c,e,tp)
	return c:IsSetCard(0x704) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:IsType(TYPE_FUSION) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c76200814.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler() or nil
	local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc) and Duel.IsCanRemoveCounter(tp,1,1,0x1704,2,REASON_COST)
	local b2=Duel.IsCanRemoveCounter(tp,1,1,0x1704,4,REASON_COST)
	local b3=aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) and Duel.IsExistingMatchingCard(c76200814.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.IsCanRemoveCounter(tp,1,1,0x1704,6,REASON_COST)
	if chk==0 then return e:IsCostChecked() and (b1 or b2 or b3) end
	local t={}
	if b1 then table.insert(t,2) end
	if b2 then table.insert(t,4) end
	if b3 then table.insert(t,6) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76200814,0))
	local ct=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.RemoveCounter(tp,1,1,0x1704,ct,REASON_COST)
	e:SetLabel(ct)
	if ct>=2 then Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD) end
	if ct>=4 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*600) end
	if ct>=6 then Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA) end
end
function c76200814.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local exc=e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.ExceptThisCard(e) or nil
	local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc) and ct>=2
	local b2=ct>=4
	local b3=aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)and Duel.IsExistingMatchingCard(c76200814.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and ct>=6
	local res=0
	if b1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc):GetFirst()
		if tc then
			Duel.HintSelection(Group.FromCards(tc))
			res=Duel.Destroy(tc,REASON_EFFECT)
		end
	end
	if b2 then
		if res~=0 then Duel.BreakEffect() end
		res=Duel.Damage(1-tp,ct*600,REASON_EFFECT)
	end
	if b3 then
		if res~=0 then Duel.BreakEffect() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local fc=Duel.SelectMatchingCard(tp,c76200814.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if fc then
			fc:SetMaterial(nil)
			Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			fc:CompleteProcedure()
		end
	end
end

function s.thfilter(c)
	return c:IsSetCard(0x704) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

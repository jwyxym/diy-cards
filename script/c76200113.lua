--升阶魔法-炽神界之印
local cm,m,o=GetID()
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+5)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,m+5)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
end
function cm.cgfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function cm.cefilter(c,tc,ct,e,tp)
	if not c:IsType(TYPE_XYZ) then return false end
	local r=c:GetRank()-tc:GetRank()
	return c:IsSetCard(0x721)
		and tc:IsCanBeXyzMaterial(c) and r>0 and ct>=r
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
function cm.cfilter(c,e,tp)
	local ct=Duel.GetMatchingGroupCount(cm.cgfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_FAIRY) and c:IsFaceup()
		and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(cm.cefilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,nil,c,ct,e,tp)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function cm.tgefilter(c,tc,e,tp,rank)
	if not c:IsType(TYPE_XYZ) then return false end
	local r=c:GetRank()-tc:GetRank()
	return c:IsSetCard(0x721)
		and tc:IsCanBeXyzMaterial(c) and r==rank
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
function cm.tgfilter(c,e,tp,rank)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_FAIRY)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(cm.tgefilter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp,rank)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cm.cfilter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingTarget(cm.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	local avail={}
	local availbool={}
	local ct=Duel.GetMatchingGroupCount(cm.cgfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	local gfield=Duel.GetMatchingGroup(cm.cfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	for tc in aux.Next(gfield) do
		local gextra=Duel.GetMatchingGroup(cm.cefilter,tp,LOCATION_EXTRA,0,nil,tc,ct,e,tp)
		for ex in aux.Next(gextra) do
			local r=ex:GetRank()-tc:GetRank()
			if not availbool[r] then
				availbool[r]=true
				table.insert(avail,r)
			end
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,1))
	local num=Duel.AnnounceNumber(tp,table.unpack(avail))
	e:SetLabel(num)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cost=Duel.SelectMatchingCard(tp,cm.cgfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,num,num,nil)
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,num)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) and tc:IsFaceup()
		and tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cm.tgefilter,tp,LOCATION_EXTRA,0,1,1,nil,tc,e,tp,e:GetLabel())
		local sc=g:GetFirst()
		if sc then
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(tc))
			Duel.Overlay(sc,Group.FromCards(tc))
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cm.splimit(e,c)
	return not c:IsRace(RACE_FAIRY) and c:IsLocation(LOCATION_EXTRA)
end
function cm.thfilter(c)
	return c:IsSetCard(0x721) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(m)
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
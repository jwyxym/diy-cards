--篡夺凭依之祸津事主
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61000203)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=aux.AddRitualProcGreater2(c,s.spfilter,LOCATION_HAND+LOCATION_GRAVE,nil,aux.TRUE,false,s.extraop)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
end
function s.cfilter(c,ec)
	return (c==ec or c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(8)) and c:IsLocation(LOCATION_HAND)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,nil,c)
	Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
	return (c:IsCode(61000203) or c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,61000203)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,61000204,0,TYPES_TOKEN_MONSTER,2500,0,8,RACE_ZOMBIE,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if Duel.IsPlayerCanSpecialSummonMonster(tp,61000204,0,TYPES_TOKEN_MONSTER,2500,0,8,RACE_ZOMBIE,ATTRIBUTE_LIGHT) then
			local token=Duel.CreateToken(tp,61000204)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.cfilter2(c,tp,se,re)
	return (c:IsReason(REASON_COST) and re:IsActivated() and re:GetHandler()==c
		or c:IsReason(REASON_BATTLE) or c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp)
		and c:IsCode(61000203)
		and (se==nil or c:GetReasonEffect()~=se) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter2,1,c,tp,se,re)
end
function s.spfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	local c=e:GetHandler()
	if tc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsRelateToChain()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and aux.NecroValleyFilter()(c)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
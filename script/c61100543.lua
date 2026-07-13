--山樱的解印「神·月」 
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,s.ffilter1,s.ffilter2,true)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	local e0a=Effect.CreateEffect(c)
	e0a:SetDescription(aux.Stringid(id,4))
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetCode(EFFECT_SPSUMMON_PROC)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCondition(s.spcon)
	e0a:SetTarget(s.sptg)
	e0a:SetOperation(s.spop)
	c:RegisterEffect(e0a)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TODECK+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+10000)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetOperation(aux.sumreg)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.ffilter1(c)
	return c:IsSetCard(0x57b) and c:IsType(TYPE_MONSTER)
end
function s.ffilter2(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_MONSTER)
end
function s.cfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x57b) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.cfilter2(c)
	return c:IsAbleToDeckAsCost() and c:IsSetCard(0x57b) and c:IsType(TYPE_MONSTER)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g2:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=g1:Select(tp,1,1,nil):GetFirst()
	sg:AddCard(sc)
	if #sg==2 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	Duel.SendtoGrave(sg,nil,REASON_SPSUMMON)
end
function s.thfilter(c,e,tp)
	return c:IsSetCard(0x57b) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgfilter(c,lv)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsLevel(lv) and c:IsAbleToGrave()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local thg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #thg<=0 then return end
	local tc=thg:GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local lv=tc:GetLevel()
		if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,lv) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tgg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
			Duel.SendtoGrave(tgg,REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
function s.stfilter(c)
	local code=c:GetCode()
	return c:IsSetCard(0x57b) and c:IsType(TYPE_MONSTER) and 
	(Duel.IsExistingMatchingCard(s.stfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,code) or
	Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_FUSION)>1)
end
function s.stfilter2(c,code)
	return c:IsSetCard(0x257b) and c:IsType(TYPE_TRAP) and aux.IsCodeListed(c,code)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) and Duel.IsExistingMatchingCard(s.ffilter2,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.HintSelection(g)
	e:SetLabelObject(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local code=tc:GetCode()
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_FUSION)>1 and 
	Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,61100548) and 
	Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and 
	Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,61100548)
		if #g>0 then
			if not Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
			end
		else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.stfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,code)
		if #g>0 then
			if Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
				Duel.ConfirmCards(1-tp,g)
				local sg=Duel.SelectMatchingCard(tp,s.ffilter2,tp,LOCATION_MZONE,0,1,1,nil)
				if #sg>0 then
					Duel.Destroy(sg,REASON_EFFECT)
			end  
		end
	end
end
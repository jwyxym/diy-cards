--
function c19993031.initial_effect(c)
	--Counter Trap activation (chain link 2+)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19993031,0))
	e0:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e0:SetCondition(c19993031.ccon)
	e0:SetCost(c19993031.ccost)
	e0:SetTarget(c19993031.ctg)
	e0:SetOperation(c19993031.cop)
	c:RegisterEffect(e0)
	--GY effect: special summon when opponent summons
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19993031,1))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,19993031+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c19993031.gycon)
	e1:SetTarget(c19993031.gytg)
	e1:SetOperation(c19993031.gyop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--xyz material level option
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_XYZ_LEVEL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c19993031.xyzlv)
	c:RegisterEffect(e3)
end
function c19993031.ccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>0
end
function c19993031.cfilter(c,tp)
	return (c:IsSetCard(0xb35) and ((c:IsType(TYPE_SYNCHRO) and c:IsLevel(12)) or (c:IsType(TYPE_XYZ) and c:IsRank(8))) and (c:IsControler(tp) or c:IsFaceup()) )or (c:IsHasEffect(19993032,tp) and c:IsControler(1-tp)) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c19993031.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19993031.cfilter,1,nil,tp) end
	local g=Duel.SelectReleaseGroup(tp,c19993031.cfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function c19993031.ctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local chain_count=Duel.GetCurrentChain()
	local dg=Group.CreateGroup()
	for i=1,chain_count do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local cp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_PLAYER)
		if cp==1-tp and te:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) then
			dg:AddCard(te:GetHandler())
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,dg,dg:GetCount(),0,0)
	if dg:GetCount()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
	end
end
function c19993031.cop(e,tp,eg,ep,ev,re,r,rp)
	local chain_count=Duel.GetCurrentChain()
	local dg=Group.CreateGroup()
	--negate opponent's effects on chain (except this card which is the highest link)
	for i=1,chain_count-1 do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local cp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_PLAYER)
		if cp==1-tp and te:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) then
			Duel.NegateActivation(i)
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	if dg:GetCount()>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function c19993031.gycon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,19993005)
end
function c19993031.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19993031.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		c:AddMonsterAttribute(TYPE_MONSTER)
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_REMOVE_TYPE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(TYPE_TRAP)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function c19993031.xyzlv(e,c)
	if c==e:GetHandler() then
		return 4,6
	else
		return c:GetLevel()
	end
end

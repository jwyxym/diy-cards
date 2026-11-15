--最凶恶的收容
local s,id,o=GetID()
local RENMIE=0x7ce1
local SHEN=57330010
local SHI=44830040

function s.initial_effect(c)
	aux.AddCodeList(c,SHEN)
	--①：从卡组把1张「人灭」卡送去墓地。也能把自己手卡·场上的1张其他的魔法·怪兽卡除外来发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：把墓地的这张卡和1张手卡除外，自己墓地·除外状态的「人灭」怪兽作为融合素材回到卡组，把1只恶魔族融合怪兽融合召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCost(s.cost3)
	e2:SetTarget(s.tg3)
	e2:SetOperation(s.op3)
	c:RegisterEffect(e2)
end

--①
function s.dfilter(c)
	return c:IsSetCard(RENMIE) and c:IsAbleToGrave()
end
function s.thfilter(c)
	return ((c:IsSetCard(RENMIE) and not c:IsCode(id)) or c:IsCode(SHEN)) and c:IsAbleToHand()
end
function s.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		return e:GetHandler():IsSetCard(RENMIE) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(SHI,tp)
	end
	return c~=e:GetHandler() and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL))
		and c:IsAbleToRemoveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()==0 then return end
	if Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9))~=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=sg:GetFirst()
	if not tc then return end
	local te=tc:IsHasEffect(SHI,tp)
	if te then
		te:UseCountLimit(tp)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
	e:SetLabel(1)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.RegisterFlagEffect(tp,RENMIE,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	if e:GetLabel()==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
	if e:GetLabel()~=1 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

--②
function s.costfilter3(c,e,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		return c:IsAbleToRemoveAsCost() and c:IsHasEffect(SHI,tp)
	end
	return c:IsAbleToRemoveAsCost()
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(s.costfilter3,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter3,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(SHI,tp)
	if te then
		te:UseCountLimit(tp)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.mfilter(c)
	return c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.fcheck(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,tp)
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)<=0 then return false end
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		return mg:GetCount()>0
			and Duel.IsExistingMatchingCard(s.fcheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)<=0 then return end
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.fcheck,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	if not tc then return end
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
	if mat:GetCount()==0 then return end
	tc:SetMaterial(mat)
	Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end

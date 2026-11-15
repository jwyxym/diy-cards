--人灭绅士
local s,id,o=GetID()
local RENMIE=0x7ce1
local SHEN=57330010
local SHI=44830040

function s.initial_effect(c)
	aux.AddCodeList(c,SHEN)
	--①：自己场上有「人灭」怪兽或「神域的物证」存在的场合才能发动。这张卡从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：这张卡召唤·特殊召唤的场合，把1张手卡除外才能发动。把自己卡组·除外状态的最多2张「神域的物证」在自己场上盖放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1000)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetCategory(CATEGORY_SSET)
	e2b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2b:SetProperty(EFFECT_FLAG_DELAY)
	e2b:SetCountLimit(1,id+1000)
	e2b:SetCost(s.cost2)
	e2b:SetTarget(s.tg2)
	e2b:SetOperation(s.op2)
	c:RegisterEffect(e2b)
	--③：「人灭」魔法卡发动过的回合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。自己墓地·除外状态有「人灭」怪兽和「神域的物证」存在的场合，卡组的「人灭」怪兽也能有最多1只作为融合素材
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+2000)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--共通：这张卡的效果发动的回合，自己不是恶魔族怪兽不能特殊召唤
function s.reglimit(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	if not c:IsRace(RACE_FIEND) then return true end
	if not c:IsType(TYPE_FUSION) then return false end
	--不用卡的效果的特殊召唤（接触融合等召唤规则）也禁止
	return se==nil or se:GetCode()==EFFECT_SPSUMMON_PROC
end

--①
function s.ctrlfilter(c)
	return (c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER)) or c:IsCode(SHEN)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	s.reglimit(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--②
function s.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		return e:GetHandler():IsSetCard(RENMIE) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(SHI,tp)
	end
	return c:IsAbleToRemoveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(SHI,tp)
	if te then
		te:UseCountLimit(tp)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.setfilter(c)
	return c:IsCode(SHEN) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsForbidden()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil)
	end
	s.reglimit(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_SZONE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then ft=1 end
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=g:Select(tp,1,math.min(2,ft),nil)
	if sg:GetCount()==0 then return end
	for tc in aux.Next(sg) do
		if Duel.SSet(tp,tc)==0 then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		end
	end
	Duel.ConfirmCards(1-tp,sg)
end

--③
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,RENMIE)~=0
end
function s.dkfilter(c)
	return c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial()
end
function s.canusedeck(tp)
	return Duel.IsExistingMatchingCard(s.dkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,SHEN)
		and Duel.IsExistingMatchingCard(s.dkfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.fcheck(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,tp)
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)<=0 then return false end
		local mg=Duel.GetFusionMaterial(tp)
		if Duel.IsExistingMatchingCard(s.fcheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg) then return true end
		if s.canusedeck(tp) then
			mg:Merge(Duel.GetMatchingGroup(s.dkfilter,tp,LOCATION_DECK,0,nil))
			return Duel.IsExistingMatchingCard(s.fcheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
		end
		return false
	end
	s.reglimit(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)<=0 then return end
	local mg=Duel.GetFusionMaterial(tp)
	if s.canusedeck(tp) then
		if Duel.SelectYesNo(tp,aux.Stringid(id,8)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local dg=Duel.SelectMatchingCard(tp,s.dkfilter,tp,LOCATION_DECK,0,1,1,nil)
			mg:Merge(dg)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.GetMatchingGroup(s.fcheck,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	if tg:GetCount()==0 then return end
	local tc=tg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
	if mat:GetCount()==0 then return end
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end

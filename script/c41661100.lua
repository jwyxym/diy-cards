--朱蒂提亚的代行·断罪
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.mfilter,3,false)
	--1回合1次用融合召唤以及以下方法才能特殊召唤（记录本回合已特召）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.flagcon)
	e0:SetOperation(s.flagop)
	c:RegisterEffect(e0)
	--特殊召唤限制（融合召唤在未用过的场合可以）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--●把手卡1张陷阱卡丢弃，把自己的手卡·场上1只暗属性「罪律」怪兽解放的场合可以从额外卡组特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--①：这张卡特殊召唤的场合，除外自己墓地1张「罪律之处断」才能发动。对方场上攻击表示的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--②：这张卡从场上离开的场合或者攻击宣言的场合才能发动。从自己的墓地·除外状态把1张暗属性「罪律」怪兽卡或者「罪律之处断」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.leavecon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
function s.mfilter(c)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_MONSTER)
end
--========== 特殊召唤限制 ==========
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
function s.flagcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
--========== 以下方法特殊召唤 ==========
function s.cfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsDiscardable(REASON_SPSUMMON)
end
function s.relfilter(c,tp)
	return c:IsSetCard(0xe9a) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER)
		and c:IsReleasable(REASON_SPSUMMON) and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		local rg=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(s.relfilter,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local tc2=rg:SelectUnselect(nil,tp,false,true,1,1)
		if tc2 then
			tc2:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD,0,1)
			local sg=Group.FromCards(tc,tc2)
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		end
	end
	return false
end
function s.disfilter(c)
	return c:GetFlagEffect(id+o)==0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	local dg=g:Filter(s.disfilter,nil)
	g:Sub(dg)
	Duel.SendtoGrave(dg,REASON_SPSUMMON+REASON_DISCARD)
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
--========== ① 破坏 + 攻0 ==========
function s.desfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
function s.costfilter(c)
	return c:IsCode(41661055) and c:IsAbleToRemoveAsCost()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local codes={}
	for tc in aux.Next(g) do
		codes[tc:GetCode()]=true
	end
	Duel.Destroy(g,REASON_EFFECT)
	--直到下个回合的结束时，那些同名卡的攻击力变为0，变为攻击表示
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return codes[c:GetCode()] end)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return codes[c:GetCode()] end)
	e2:SetValue(POS_FACEUP_ATTACK)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2,tp)
	--当前在场的同名卡立即转为攻击表示
	local pg=Duel.GetMatchingGroup(function(c) return codes[c:GetCode()] and c:IsPosition(POS_FACEUP_DEFENSE) end,tp,0,LOCATION_MZONE,nil)
	if pg:GetCount()>0 then
		Duel.ChangePosition(pg,POS_FACEUP_ATTACK)
	end
end
--========== ② 回收 ==========
function s.leavecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thfilter(c)
	if not (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) then return false end
	if c:IsCode(41661055) then return c:IsAbleToHand() end
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

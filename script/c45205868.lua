--隔岸观火
local s,id=GetID()
function s.initial_effect(c)
	--① 把自己场上的怪兽直到回合结束除外才能发动。这个回合，自己不会受到战斗·效果伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- cost：把自己场上全部怪兽直到回合结束除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_TEMPORARY)==0 then return end
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if og:GetCount()==0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	for tc in aux.Next(og) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
	og:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(fid)
	e1:SetLabelObject(og)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	Duel.RegisterEffect(e1,tp)
end

-- 返回条件：还有本次除外的卡在除外区
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil,e:GetLabel()) then
		e:GetLabelObject():DeleteGroup()
		e:Reset()
		return false
	end
	return true
end

-- 返回处理：格子够则返回，不够则玩家选部分返回，其余规则送墓
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject():Filter(s.retfilter,nil,fid)
	if #g<=0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then
		-- 没有空位，全部规则送墓
		Duel.SendtoGrave(g,REASON_RULE)
	elseif #g>ft then
		-- 格子不够，玩家选 ft 张返回，其余规则送墓
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:Select(tp,ft,ft,nil)
		for tc in aux.Next(sg) do
			Duel.ReturnToField(tc)
		end
		g:Sub(sg)
		Duel.SendtoGrave(g,REASON_RULE)
	else
		-- 格子够，全部返回
		for tc in aux.Next(g) do
			Duel.ReturnToField(tc)
		end
	end
	e:GetLabelObject():DeleteGroup()
end

-- target
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

-- operation：这个回合自己不受战斗·效果伤害
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 战斗伤害为0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- 效果伤害为0
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.damval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	Duel.RegisterEffect(e2b,tp)
end

-- 效果伤害变0
function s.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end

return s
